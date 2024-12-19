//
//  CardThumbnailView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/15/24.
//

import SwiftData
import SwiftUI

struct ThumbnailView: View {
    let card: CardSchemaV1.StereoCard
    var navigationEnabled = true  // Add flag to control navigation

    @Environment(\.imageCache) private var imageCache
    @State private var image: CGImage?
    @State private var loadingError = false
    @State private var isLoading = false

    var body: some View {
        Group {
            if navigationEnabled {
                NavigationLink(destination: CardDetailView(card: card)) {
                    thumbnailContent
                }
                .buttonStyle(.plain)
            } else {
                thumbnailContent
            }
        }
        .task {
            await loadCachedImage()
        }
    }

    private var thumbnailContent: some View {
        ZStack {
            if let image {
                Image(decorative: image, scale: 1.0)
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                placeholderView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aspectRatio(2, contentMode: .fit)
    }

    private var placeholderView: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.gray.opacity(0.2))
            .overlay {
                if loadingError {
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

    private func loadCachedImage() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        // Check cache first
        if let imageId = card.imageFrontId,
            let cached = imageCache.image(for: imageId)
        {
            image = cached
            return
        }

        // Load if not cached
        do {
            if let thumbnail = try await card.loadGridThumbnail() {
                image = thumbnail
                if let imageId = card.imageFrontId {
                    imageCache.cache(thumbnail, for: imageId)
                }
            }
        } catch {
            loadingError = true
        }
    }
}
