//
//  StereoGalleryView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/27/24.
//

#if os(visionOS)
    import QuickLook
    import SwiftUI
    import SwiftData

    struct StereoGalleryView: View {
        let cards: [CardSchemaV1.StereoCard]
        let initialCard: CardSchemaV1.StereoCard?

        @Environment(\.dismiss) private var dismiss
        @Environment(\.imageLoader) private var imageLoader

        @State private var processedCards = 0
        @State private var isProcessing = false
        @State private var previewSession: PreviewSession?
        private let spatialManager: SpatialPhotoManager

        init(
            cards: [CardSchemaV1.StereoCard],
            initialCard: CardSchemaV1.StereoCard? = nil
        ) {
            self.cards = cards
            self.initialCard = initialCard
            // Initialize manager with the first card's context
            if let context = cards.first?.modelContext {
                self.spatialManager = SpatialPhotoManager(modelContext: context)
            } else {
                // Fallback to a new context if needed
                self.spatialManager = SpatialPhotoManager(
                    modelContext: ModelContext(
                        try! ModelContainer(for: CardSchemaV1.StereoCard.self)))
            }
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
                await processCards()
            }
            .onDisappear {
                Task {
                    if let session = previewSession {
                        try? await session.close()
                        previewSession = nil
                    }
                }
            }
        }

        private func processCards() async {
            guard let imageLoader = imageLoader else { return }

            isProcessing = true
            defer { isProcessing = false }

            var previewItems: [PreviewItem] = []
            var initialIndex = 0

            for (index, card) in cards.enumerated() {
                do {
                    // Load high quality image for processing
                    if let sourceImage = try await imageLoader.loadImage(
                        for: card,
                        side: .front,
                        quality: .high
                    ) {
                        // Get preview item
                        let previewItem = try await card.getOrCreatePreviewItem(
                            sourceImage: sourceImage)
                        previewItems.append(previewItem)

                        // Track initial card index
                        if card.id == initialCard?.id {
                            initialIndex = index
                        }
                    }
                } catch {
                    print("Failed to process card \(card.uuid): \(error)")
                }

                processedCards = index + 1
            }

            // Open all cards in QuickLook
            if !previewItems.isEmpty {
                previewSession = PreviewApplication.open(
                    items: previewItems,
                    selectedItem: previewItems[initialIndex]
                )
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
                    .serifNavigationTitle("Gallery")
            }
        }
    }

    #Preview("Single Card Gallery") {
        NavigationStack {
            CardPreviewContainer { card in
                StereoGalleryView(cards: [card], initialCard: card)
                    .frame(minWidth: 800, minHeight: 600)
                    .serifNavigationTitle("Single Card Gallery")
            }
        }
    }
#endif
