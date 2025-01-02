//
//  CardActionMenu.swift
//  Retroview
//
//  Created by Adam Schuster on 1/1/25.
//

import QuickLook
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct CardActionMenu: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.imageLoader) private var imageLoader
    @Environment(\.spatialPhotoManager) private var spatialPhotoManager

    let card: CardSchemaV1.StereoCard

    @State private var showingCollectionSheet = false
    @State private var showingShareSheet = false
    @State private var isReloadingImages = false
    #if os(macOS)
    @State private var shareSheetAnchor: NSView?
    #endif

    var body: some View {
        Menu {
            Button {
                Task {
                    // Ensure spatial photo exists before sharing
                    if card.spatialPhotoData == nil,
                        let imageLoader = imageLoader,
                        let sourceImage = try await imageLoader.loadImage(
                            for: card,
                            side: .front,
                            quality: .ultra)
                    {
                        do {
                            _ =
                                try await spatialPhotoManager
                                .getSpatialPhotoData(
                                    for: card,
                                    sourceImage: sourceImage
                                )
                        } catch {
                            print("Failed to create spatial photo: \(error)")
                            return
                        }
                    }
                    showingShareSheet = true
                }
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Share Spatial Card...")
                }
            }

            // Rest of menu items...
            #if os(visionOS)
                Button {
                    Task {
                        guard let imageLoader = imageLoader,
                            let _ = try await imageLoader.loadImage(
                                for: card,
                                side: .front,
                                quality: .ultra)
                        else { return }

                        let _ = try await PreviewApplication.openCards(
                            [card],
                            selectedCard: card,
                            imageLoader: imageLoader
                        )
                    }
                } label: {
                    HStack {
                        Image(systemName: "view.3d")
                        Text("View in Space")
                    }
                }
            #endif

            Menu {
                CardCollectionSubmenu(
                    card: card,
                    showingCollectionSheet: $showingCollectionSheet
                )
            } label: {
                HStack {
                    Image(systemName: "folder.badge.plus")
                    Text("Add to Collection")
                }
            }

            Divider()

            Button {
                Task {
                    isReloadingImages = true
                    defer { isReloadingImages = false }

                    let managers = [
                        CardImageManager(
                            card: card, side: .front, quality: .thumbnail),
                        CardImageManager(
                            card: card, side: .front, quality: .standard),
                        CardImageManager(
                            card: card, side: .back, quality: .thumbnail),
                        CardImageManager(
                            card: card, side: .back, quality: .standard),
                    ]

                    for manager in managers {
                        guard let url = manager.imageURL else { continue }
                        do {
                            let (data, _) = try await URLSession.shared.data(
                                from: url)
                            await MainActor.run {
                                manager.storeImageData(data)
                            }
                        } catch {
                            print("Failed to reload image: \(error)")
                        }
                    }

                    try? modelContext.save()
                }
            } label: {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Reload Images")
                }
            }
            .disabled(isReloadingImages)
        } label: {
            Image(systemName: "ellipsis.circle")
                .font(.title2)
                .foregroundStyle(.white)
                .shadow(radius: 2)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingCollectionSheet) {
            CollectionCreationView(card: card)
        }
        .sheet(isPresented: $showingShareSheet) {
            let items: [Any] = [
                card.temporarySpatialPhotoURL as Any,
                card.titlePick?.text ?? "Untitled Card",
            ].compactMap { $0 }

            #if os(macOS)
                MacShareSheet(items: items, sourceView: shareSheetAnchor)
            #else
                SystemShareSheet(items: items)
            #endif
        }
        #if os(macOS)
            .background {
                // Invisible anchor view for share sheet positioning
                Color.clear
                .frame(width: 1, height: 1)
                .allowsHitTesting(false)
                .background {
                    GeometryReader { proxy in
                        Color.clear
                        .onAppear {
                            if let window = NSApp.keyWindow,
                                let contentView = window.contentView
                            {
                                let frame = proxy.frame(in: .global)
                                let anchor = NSView(
                                    frame: NSRect(
                                        x: frame.minX,
                                        y: frame.minY,
                                        width: 1,
                                        height: 1
                                    ))
                                contentView.addSubview(anchor)
                                shareSheetAnchor = anchor
                            }
                        }
                    }
                }
            }
        #endif
    }
}

#if os(macOS)
    private struct MacShareSheet: View {
        let items: [Any]
        let sourceView: NSView?
        @Environment(\.dismiss) private var dismiss

        var body: some View {
            EmptyView()
                .onAppear {
                    let picker = NSSharingServicePicker(items: items)
                    if let sourceView = sourceView {
                        picker.show(
                            relativeTo: sourceView.bounds,
                            of: sourceView,
                            preferredEdge: .minY
                        )
                    } else {
                        // Fallback to window center if no anchor
                        picker.show(
                            relativeTo: .zero,
                            of: NSApp.keyWindow?.contentView ?? NSView(),
                            preferredEdge: .minY
                        )
                    }
                    dismiss()
                }
        }
    }
#else
    private struct SystemShareSheet: UIViewControllerRepresentable {
        let items: [Any]

        func makeUIViewController(context: Context) -> UIActivityViewController
        {
            UIActivityViewController(
                activityItems: items,
                applicationActivities: nil
            )
        }

        func updateUIViewController(
            _ uiViewController: UIActivityViewController,
            context: Context
        ) {}
    }
#endif

#Preview {
    CardPreviewContainer { card in
        CardActionMenu(card: card)
    }
}
