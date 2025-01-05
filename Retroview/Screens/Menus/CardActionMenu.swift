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
    @Binding var showDirectMenu: Bool

    @State private var showingCollectionSheet = false
    @State private var showingShareSheet = false
    @State private var isReloadingImages = false
    @State private var isGeneratingShareData = false

    var body: some View {
        if showDirectMenu {
            CardActionMenuContent(
                card: card,
                onShare: handleShare,
                onViewInSpace: handleViewInSpace,
                onAddToCollection: { showingCollectionSheet = true },
                onReloadImages: handleReloadImages
            )
            .sheet(isPresented: $showingCollectionSheet) {
                CollectionCreationView(card: card)
            }
            #if os(visionOS)
                .sheet(isPresented: $showingShareSheet) {
                    let shareURL = card.createSharingURL()
                    SystemShareSheet(items: [shareURL].compactMap { $0 })
                }
            #endif
        } else {
            Menu {
                Button(action: handleShare) {
                    menuLabel(
                        icon: "square.and.arrow.up",
                        text: "Share Spatial Card...")
                }
                #if os(visionOS)
                    Button(action: handleViewInSpace) {
                        menuLabel(icon: "view.3d", text: "View in Space")
                    }
                #endif
                Menu {
                    CardCollectionSubmenu(
                        card: card,
                        showingCollectionSheet: $showingCollectionSheet
                    )
                } label: {
                    menuLabel(
                        icon: "folder.badge.plus", text: "Add to Collection")
                }
                Divider()
                Button(action: handleReloadImages) {
                    menuLabel(icon: "arrow.clockwise", text: "Reload Images")
                }
                .disabled(isReloadingImages)
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .shadow(radius: 2)
            }
            .buttonStyle(.plain)
            .platformInteraction(
                InteractionConfig(
                    showHoverEffects: true
                )
            )
        }
    }

    // MARK: - Action Handlers

    private func handleShare() {
        Task {
            isGeneratingShareData = true
            defer { isGeneratingShareData = false }

            if card.spatialPhotoData == nil,
                let imageLoader = imageLoader,
                let sourceImage = try await imageLoader.loadImage(
                    for: card, side: .front, quality: .ultra)
            {
                do {
                    _ = try await spatialPhotoManager.getSpatialPhotoData(
                        for: card, sourceImage: sourceImage)
                } catch {
                    print("Failed to create spatial photo: \(error)")
                    return
                }
            }
            showingShareSheet = true
        }
    }

    private func handleViewInSpace() {
        #if os(visionOS)
            Task {
                guard let imageLoader = imageLoader,
                    (try await imageLoader.loadImage(
                        for: card, side: .front, quality: .high)) != nil
                else { return }
                let _ = try await PreviewApplication.openCards(
                    [card], selectedCard: card, imageLoader: imageLoader)
            }
        #endif
    }

    private func handleReloadImages() {
        Task {
            isReloadingImages = true
            defer { isReloadingImages = false }

            let managers = [
                CardImageManager(card: card, side: .front, quality: .thumbnail),
                CardImageManager(card: card, side: .front, quality: .standard),
                CardImageManager(card: card, side: .back, quality: .thumbnail),
                CardImageManager(card: card, side: .back, quality: .standard),
            ]

            for manager in managers {
                guard let url = manager.imageURL else { continue }
                do {
                    let (data, _) = try await URLSession.shared.data(from: url)
                    await MainActor.run { manager.storeImageData(data) }
                } catch {
                    print("Failed to reload image: \(error)")
                }
            }

            try? modelContext.save()
        }
    }

    // MARK: - Helper View for Menu Labels

    private func menuLabel(icon: String, text: String) -> some View {
        HStack {
            Image(systemName: icon)
            Text(text)
        }
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

extension CardSchemaV1.StereoCard {
    func createSharingURL() -> URL? {
        guard let spatialData = spatialPhotoData else { return nil }

        let title = titlePick?.text ?? "Untitled Card"
        // Sanitize filename by removing invalid characters
        let sanitizedTitle = title.replacingOccurrences(
            of: "[/\\?%*|\"<>]", with: "-", options: .regularExpression)

        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(sanitizedTitle)
            .appendingPathExtension("heic")

        do {
            try spatialData.write(to: tempURL)
            // Set UTType for HEIC image
            try (tempURL as NSURL).setResourceValue(
                UTType.heic.identifier,
                forKey: .typeIdentifierKey
            )
            // Mark as readable to other apps
            try (tempURL as NSURL).setResourceValue(
                true,
                forKey: .isReadableKey
            )
            return tempURL
        } catch {
            print("Failed to create sharing URL: \(error)")
            return nil
        }
    }
}

#Preview("Direct Menu") {
    CardPreviewContainer { card in
        CardActionMenu(card: card, showDirectMenu: .constant(true))
    }
}

#Preview("Button Menu") {
    CardPreviewContainer { card in
        CardActionMenu(card: card, showDirectMenu: .constant(false))
    }
}
