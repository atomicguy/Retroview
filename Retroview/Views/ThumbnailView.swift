//
//  CardThumbnailView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/15/24.
//

import QuickLook
import SwiftData
import SwiftUI

struct ThumbnailView: View {
    @Environment(\.imageLoader) private var imageLoader
    let card: CardSchemaV1.StereoCard
    @State private var image: CGImage?
    @State private var isLoading = false
    @State private var loadError = false
    @State private var isHovering = false
    @State private var previewSession: PreviewSession?

    var body: some View {
        ZStack {
            if let image {
                Image(decorative: image, scale: 1.0)
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay {
                        ThumbnailOverlay(card: card, isHovering: isHovering)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .onHover { hovering in
                        isHovering = hovering
                    }
            } else {
                placeholderView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aspectRatio(2, contentMode: .fit)
        .task {
            await loadImage()
        }
        .shareable(card: card)
        .contextMenu {
            if let data = card.spatialPhotoData,
                let url = card.writeToTemporary(data: data)
            {
                Button {
                    previewSession = PreviewApplication.open(urls: [url])
                } label: {
                    Label("View in Stereo", systemImage: "view.3d")
                }
            }
        }
    }

    private var placeholderView: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.gray.opacity(0.2))
            .overlay {
                if loadError {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                } else if isLoading {
                    ProgressView()
                } else {
                    Image(systemName: "photo")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
            }
    }

    @MainActor
    private func loadImage() async {
        guard !isLoading, let imageLoader else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            image = try await imageLoader.loadImage(
                for: card,
                side: .front,
                quality: .thumbnail
            )
        } catch {
            loadError = true
        }
    }
}

#Preview("Thumbnail View") {
    if let card = try? PreviewDataManager.shared.container().mainContext.fetch(
        FetchDescriptor<CardSchemaV1.StereoCard>()
    ).first {
        ThumbnailView(card: card)
            .withPreviewStore()
            .environment(\.imageLoader, CardImageLoader())
            .frame(width: 300, height: 200)
    } else {
        ContentUnavailableView("No Preview Card", systemImage: "photo")
            .withPreviewStore()
    }
}
