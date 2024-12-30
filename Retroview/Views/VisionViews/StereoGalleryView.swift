//
//  StereoGalleryView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/27/24.
//

#if os(visionOS)
    import QuickLook
    import SwiftUI

    struct StereoGalleryView: View {
        let cards: [CardSchemaV1.StereoCard]
        let initialCard: CardSchemaV1.StereoCard?

        @Environment(\.dismiss) private var dismiss
        @Environment(\.imageLoader) private var imageLoader

        // Track processing state
        @State private var processedCards = 0
        @State private var isProcessing = false
        @State private var previewSession: PreviewSession?

        init(
            cards: [CardSchemaV1.StereoCard],
            initialCard: CardSchemaV1.StereoCard? = nil
        ) {
            self.cards = cards
            self.initialCard = initialCard
        }

        var body: some View {
            ZStack {
                // Transparent background
                Color.clear

                // Processing indicator
                if isProcessing {
                    VStack {
                        ProgressView(
                            "Processing \(processedCards) of \(cards.count)"
                        )
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
            .frame(width: 200, height: 100)
            .task {
                // Create spatial photos for any cards that need them
                await processAllCards()

                // Open all cards in QuickLook
                previewSession = PreviewApplication.openCards(
                    cards, selectedCard: initialCard)
            }
            .onDisappear {
                // Use Task to handle async cleanup
                Task {
                    if let session = previewSession {
                        try? await session.close()
                        previewSession = nil
                    }
                }
            }
        }

        private func processAllCards() async {
            guard let imageLoader = imageLoader else { return }

            isProcessing = true
            defer { isProcessing = false }

            for (index, card) in cards.enumerated() {
                // Skip if card already has spatial photo
                guard card.spatialPhotoData == nil else { continue }

                do {
                    // Load high quality image for spatial processing
                    if let sourceImage = try await imageLoader.loadImage(
                        for: card,
                        side: .front,
                        quality: .high
                    ) {
                        // Create spatial photo
                        let manager = SpatialPhotoManager(
                            modelContext: card.modelContext!)
                        try await manager.createSpatialPhoto(
                            from: card, sourceImage: sourceImage)
                    }
                } catch {
                    print("Failed to process card \(card.uuid): \(error)")
                }

                processedCards = index + 1
            }
        }
    }

    #Preview("Stereo Gallery - Multiple Cards") {
        NavigationStack {
            CardsPreviewContainer(
                count: 5,
                where: { card in
                    // Only show cards with images and crops
                    card.imageFrontId != nil && card.leftCrop != nil
                }
            ) { cards in
                StereoGalleryView(cards: cards)
                    .frame(minWidth: 800, minHeight: 600)
                    .navigationTitle("Gallery")
            }
        }
    }

    #Preview("Single Card Gallery") {
        NavigationStack {
            CardPreviewContainer { card in
                StereoGalleryView(cards: [card], initialCard: card)
                    .frame(minWidth: 800, minHeight: 600)
                    .navigationTitle("Single Card Gallery")
            }
        }
    }
#endif
