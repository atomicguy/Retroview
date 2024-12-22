//
//  CardImageSection.swift
//  Retroview
//
//  Created by Adam Schuster on 12/17/24.
//

import SwiftUI

struct CardImageSection: View {
    @Environment(\.imageLoader) private var imageLoader
    let card: CardSchemaV1.StereoCard
    let side: CardSide
    let title: String

    @State private var image: CGImage?
    @State private var thumbnailImage: CGImage?
    @State private var isLoading = false
    @State private var loadError = false
    @State private var isFullImageLoaded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(.headline, design: .serif))
                .foregroundStyle(.secondary)

            if (side == .front
                ? card.imageFrontId : card.imageBackId) != nil
            {
                ZStack {
                    // Show stored thumbnail until full image loads
                    if let thumbnailImage {
                        Image(decorative: thumbnailImage, scale: 1.0)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .opacity(isFullImageLoaded ? 0 : 1)
                    }

                    if let image {
                        Image(decorative: image, scale: 1.0)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .onAppear {
                                withAnimation(.easeIn(duration: 0.3)) {
                                    isFullImageLoaded = true
                                }
                            }
                    } else if loadError {
                        errorPlaceholder
                    } else if isLoading && thumbnailImage == nil {
                        loadingPlaceholder
                    }
                }
                .task {
                    await loadImages()
                }
            }
        }
    }

    private var loadingPlaceholder: some View {
        Rectangle()
            .fill(.gray.opacity(0.1))
            .aspectRatio(2 / 1, contentMode: .fit)
            .overlay {
                ProgressView()
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var errorPlaceholder: some View {
        Rectangle()
            .fill(.gray.opacity(0.1))
            .aspectRatio(2 / 1, contentMode: .fit)
            .overlay {
                Label("Failed to load", systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.secondary)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    @MainActor
    private func loadImages() async {
        guard !isLoading, let imageLoader else { return }
        isLoading = true
        loadError = false

        // First load thumbnail
        do {
            thumbnailImage = try await imageLoader.loadImage(
                for: card,
                side: side,
                quality: .thumbnail
            )
        } catch {
            print("Failed to load thumbnail: \(error)")
        }

        // Then load high quality image
        do {
            image = try await imageLoader.loadImage(
                for: card,
                side: side,
                quality: .high
            )
        } catch {
            loadError = true
            print("Failed to load high quality image: \(error)")
        }

        isLoading = false
    }
}
