//
//  ShareButton.swift
//  Retroview
//
//  Created by Adam Schuster on 1/10/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct CardShareButton: View {
    @Environment(\.spatialPhotoManager) private var spatialManager
    @Environment(\.imageLoader) private var imageLoader
    let card: CardSchemaV1.StereoCard

    @State private var isPreparingShare = false
    @State private var sharingURL: URL?

    var body: some View {
        Group {
            if isPreparingShare {
                Button {
                    // Show loading state
                } label: {
                    ProgressView()
                        .controlSize(.small)
                }
                .disabled(true)
            } else if let url = sharingURL {
                ShareLink(
                    item: url,
                    preview: SharePreview(
                        card.titlePick?.text ?? "Stereo Card",
                        image: sfSymbolAsImageData
                    )
                )
            } else {
                Button {
                    prepareSpatialPhoto()
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
            }
        }
    }

    private func prepareSpatialPhoto() {
        guard let manager = spatialManager,
            let loader = imageLoader
        else { return }

        Task { @MainActor in
            isPreparingShare = true

            do {
                sharingURL = try await manager.prepareForSharing(
                    card: card,
                    imageLoader: loader
                )
            } catch {
                print("Failed to prepare for sharing: \(error)")
            }

            isPreparingShare = false
        }
    }

    private var sfSymbolAsImageData: Image {
        #if os(macOS)
            if let nsImage = NSImage(
                systemSymbolName: "photo.3d",
                accessibilityDescription: "3D Photo"
            ) {
                return Image(nsImage: nsImage)
            }
        #else
            if let uiImage = UIImage(
                systemName: "photo.3d",
                withConfiguration: UIImage.SymbolConfiguration(
                    pointSize: 100, weight: .regular)
            ) {
                return Image(uiImage: uiImage)
            }
        #endif
        return Image(systemName: "photo.3d")
    }
}

#Preview {
    CardPreviewContainer { card in
        CardShareButton(card: card)
            .padding()
    }
}
