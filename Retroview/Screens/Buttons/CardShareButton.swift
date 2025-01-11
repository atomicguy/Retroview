//
//  ShareButton.swift
//  Retroview
//
//  Created by Adam Schuster on 1/10/25.
//

import SwiftUI

struct CardShareButton: View {
    @Environment(\.spatialPhotoManager) private var spatialManager
    @Environment(\.imageLoader) private var imageLoader
    let card: CardSchemaV1.StereoCard

    @State private var isPreparingShare = false
    @State private var isShowingShareSheet = false
    @State private var sharingURL: URL?

    var body: some View {
        Button {
            guard let manager = spatialManager,
                let loader = imageLoader
            else { return }

            Task { @MainActor in
                guard !isPreparingShare else { return }
                isPreparingShare = true

                do {
                    sharingURL = try await manager.prepareForSharing(
                        card: card,
                        imageLoader: loader
                    )
                    // Show appropriate sharing UI for platform
                    if let url = sharingURL {
                        #if os(macOS)
                            NSSharingService.share(items: [url])
                        #else
                            isShowingShareSheet = true
                        #endif
                    }
                } catch {
                    print("Failed to prepare for sharing: \(error)")
                }

                isPreparingShare = false
            }
        } label: {
            if isPreparingShare {
                ProgressView()
                    .controlSize(.small)
            } else {
                Label("Share", systemImage: "square.and.arrow.up")
            }
        }
        .disabled(isPreparingShare)
        #if !os(macOS)
            .sheet(isPresented: $isShowingShareSheet) {
                if let url = sharingURL {
                    ShareSheet(items: [url])
                }
            }
        #endif
    }
}

#if os(macOS)
    extension NSSharingService {
        static func share(items: [Any]) {
            let picker = NSSharingServicePicker(items: items)
            picker.show(
                relativeTo: .zero, of: NSApp.keyWindow?.contentView ?? NSView(),
                preferredEdge: .minY)
        }
    }
#else
    struct ShareSheet: UIViewControllerRepresentable {
        let items: [Any]

        func makeUIViewController(context: Context) -> UIActivityViewController
        {
            UIActivityViewController(
                activityItems: items, applicationActivities: nil)
        }

        func updateUIViewController(
            _ uiViewController: UIActivityViewController, context: Context
        ) {}
    }
#endif

#Preview {
    CardPreviewContainer { card in
        CardShareButton(card: card)
            .padding()
    }
}
