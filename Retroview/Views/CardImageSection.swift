//
//  CardImageSection.swift
//  Retroview
//
//  Created by Adam Schuster on 12/17/24.
//

import SwiftUI

struct CardImageSection: View {
    let card: CardSchemaV1.StereoCard
    let side: CardSide
    let title: String

    @State private var imageManager: CardImageManager?
    @State private var thumbnailManager: CardImageManager?
    @State private var isFullImageLoaded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(.headline, design: .serif))
                .foregroundStyle(.secondary)

            if let imageId = side == .front
                ? card.imageFrontId : card.imageBackId
            {
                ZStack {
                    // Show stored thumbnail until full image loads
                    if let thumbnailImage = thumbnailManager?.storedImage {
                        Image(decorative: thumbnailImage, scale: 1.0)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .opacity(isFullImageLoaded ? 0 : 1)
                    }

                    // Load high quality image
                    AsyncImage(
                        url: URL(
                            string:
                                "https://iiif-prod.nypl.org/index.php?id=\(imageId)&t=\(ImageQuality.high.rawValue)"
                        )
                    ) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .onAppear {
                                    withAnimation(.easeIn(duration: 0.3)) {
                                        isFullImageLoaded = true
                                    }
                                }
                        case .failure:
                            errorPlaceholder
                        case .empty:
                            if thumbnailManager?.storedImage == nil {
                                loadingPlaceholder
                            }
                        @unknown default:
                            EmptyView()
                        }
                    }
                }
                .task {
                    if imageManager == nil {
                        imageManager = CardImageManager(
                            card: card, side: side, quality: .high)
                    }
                    if thumbnailManager == nil {
                        thumbnailManager = CardImageManager(
                            card: card, side: side, quality: .thumbnail)
                    }
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
}
