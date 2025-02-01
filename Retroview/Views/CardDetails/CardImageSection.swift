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
    let showCrops: Bool

    @State private var thumbnailImage: CGImage?
    @State private var fullImage: CGImage?
    @State private var isLoadingFullImage = false
    @State private var loadError = false

    init(
        card: CardSchemaV1.StereoCard,
        side: CardSide,
        title: String,
        showCrops: Bool = false
    ) {
        self.card = card
        self.side = side
        self.title = title
        self.showCrops = showCrops
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
//            Text(title)
//                .font(.system(.headline, design: .serif))
//                .foregroundStyle(.secondary)

            if (side == .front
                ? card.imageFrontId : card.imageBackId) != nil
            {
                ZStack(alignment: .bottom) {
                    // Thumbnail layer (always show if available)
                    if let thumbnailImage {
                        Image(decorative: thumbnailImage, scale: 1.0)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay(
                                // Loading indicator over thumbnail
                                isLoadingFullImage
                                    ? ProgressView()
                                        .scaleEffect(0.7)
                                        .padding(8)
                                    : nil
                            )
                    }

                    // Full image layer
                    if let fullImage {
                        Image(decorative: fullImage, scale: 1.0)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .overlay {
                                if showCrops {
                                    CropRectanglesView(
                                        leftCrop: card.leftCrop,
                                        rightCrop: card.rightCrop
                                    )
                                }
                            }
                            .transition(.opacity)
                    }

                    // Fallback placeholders
                    if thumbnailImage == nil {
                        placeholderWithIcon
                    }
                }
                .animation(.default, value: fullImage)
                .task(id: card.uuid) {
                    await loadImages()
                }
            }
        }
    }

    private var placeholderWithIcon: some View {
        Rectangle()
            .fill(.gray.opacity(0.1))
            .aspectRatio(2 / 1, contentMode: .fit)
            .overlay {
                Image(systemName: "photo")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    @MainActor
    private func loadImages() async {
        guard let imageLoader else { return }

        // Always try to load thumbnail first
        do {
            thumbnailImage = try await imageLoader.loadImage(
                for: card,
                side: side,
                quality: .thumbnail
            )
        } catch {
            print("Failed to load thumbnail: \(error)")
        }

        // Then start loading full image
        do {
            isLoadingFullImage = true
            fullImage = try await imageLoader.loadImage(
                for: card,
                side: side,
                quality: .high
            )
        } catch {
            loadError = true
            print("Failed to load high quality image: \(error)")
        }

        isLoadingFullImage = false
    }
}

#if DEBUG
    import SwiftData

    #Preview("Card Image Section") {
        let previewContainer = try! PreviewDataManager.shared.container()
        let card = try! previewContainer.mainContext.fetch(
            FetchDescriptor<CardSchemaV1.StereoCard>()
        ).first!

        return CardImageSection(card: card, side: .front, title: "Front Image")
            .withPreviewStore()
            .environment(\.imageLoader, CardImageLoader())
            .padding()
    }

    #Preview("Card Image Section - With Crops") {
        let previewContainer = try! PreviewDataManager.shared.container()
        let card = try! previewContainer.mainContext.fetch(
            FetchDescriptor<CardSchemaV1.StereoCard>()
        ).first!

        return CardImageSection(
            card: card, side: .front, title: "Front Image", showCrops: true
        )
        .withPreviewStore()
        .environment(\.imageLoader, CardImageLoader())
        .padding()
    }
#endif
