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
        @State private var selectedIndex: Int
        @State private var previewSession: PreviewSession?

        // Track processing state
        @State private var processedCards = 0
        @State private var isProcessing = false

        // Gesture state
        @GestureState private var dragOffset: CGFloat = 0

        init(
            cards: [CardSchemaV1.StereoCard],
            initialCard: CardSchemaV1.StereoCard? = nil
        ) {
            self.cards = cards
            self.initialCard = initialCard
            self._selectedIndex = State(
                initialValue: initialCard.flatMap { cards.firstIndex(of: $0) }
                    ?? 0)
        }

        var body: some View {
            ZStack {

                // Completely transparent background
                Color.clear

                // Invisible gesture layer
                Rectangle()
                    .fill(Color.clear)
                    .opacity(0)
                    .contentShape(Rectangle())
                    .gesture(
                        DragGesture()
                            .updating($dragOffset) { value, state, _ in
                                state = value.translation.width
                            }
                            .onEnded { value in
                                let threshold: CGFloat = 50
                                if value.translation.width > threshold
                                    && selectedIndex > 0
                                {
                                    selectedIndex -= 1
                                } else if value.translation.width < -threshold
                                    && selectedIndex < cards.count - 1
                                {
                                    selectedIndex += 1
                                }
                            }
                    )

                // Thumbnail strip at bottom
                VStack {
                    Spacer()

                    if !cards.isEmpty {
                        StereoGalleryStrip(
                            cards: cards,
                            selectedIndex: $selectedIndex,
                            onSelectionChanged: { card in
                                Task {
                                    await updatePreviewSession(for: card)
                                }
                            }
                        )
                        .padding(.bottom)
                    }
                    // Processing indicator
                    if isProcessing {
                        VStack {
                            ProgressView(
                                "Processing \(processedCards) of \(cards.count)"
                            )
                            .padding()
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            Spacer()
                        }
                        .padding(.top)
                    } else {
                        EmptyView()
                    }
                }
            }
            .task {
                // Create spatial photos for all cards
                await processAllCards()

                // Start the preview session for initial card
                if let card = initialCard ?? cards.first {
                    await updatePreviewSession(for: card)
                }
            }
            .onChange(of: selectedIndex) { _, newIndex in
                if let card = cards[safe: newIndex] {
                    Task {
                        await updatePreviewSession(for: card)
                    }
                }
            }
            .onAppear {
                if let card = initialCard ?? cards.first {
                    Task {
                        await updatePreviewSession(for: card)
                    }
                }
            }
            .onDisappear {
                Task {
                    await closePreviewSession()
                }
            }
        }

        private func closePreviewSession() async {
            if let session = previewSession {
                do {
                    try await session.close()
                    previewSession = nil  // Ensure this is cleared before starting a new session
                } catch {
                    print(
                        "Failed to close preview session: \(error.localizedDescription)"
                    )
                }
            }
        }

        private func updatePreviewSession(for card: CardSchemaV1.StereoCard)
            async
        {
            print("Starting to update preview session for card \(card.uuid) from \(Thread.callStackSymbols)")
            await closePreviewSession()
            print("Closed existing preview session")

            guard let data = card.spatialPhotoData else {
                print("Card \(card.uuid) has no spatial photo data")
                return
            }

            guard let url = card.writeToTemporary(data: data) else {
                print(
                    "Failed to write spatial photo data to temporary URL for card \(card.uuid)"
                )
                return
            }

            do {
                previewSession = PreviewApplication.open(items: [
                    card.asPreviewItem(url: url)
                ])
                print("Opened new preview session for card \(card.uuid)")
            } catch {
                print(
                    "Error opening preview session: \(error.localizedDescription)"
                )
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

    // Helper extension for safe array access
    extension Collection {
        subscript(safe index: Index) -> Element? {
            indices.contains(index) ? self[index] : nil
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
                StereoGalleryView(cards: cards, initialCard: cards.first)
                    .frame(minWidth: 800, minHeight: 600)
                    .navigationTitle("Gallery")
            }
        }
    }

    #Preview("Stereo Gallery - Single Card") {
        NavigationStack {
            CardPreviewContainer { card in
                StereoGalleryView(cards: [card], initialCard: card)
                    .frame(minWidth: 800, minHeight: 600)
                    .navigationTitle("Single Card Gallery")
            }
        }
    }

    #Preview("Stereo Gallery - Empty State") {
        NavigationStack {
            StereoGalleryView(cards: [], initialCard: nil)
                .frame(minWidth: 800, minHeight: 600)
                .navigationTitle("Empty Gallery")
        }
    }

    #Preview("Gallery Strip Only") {
        CardsPreviewContainer(count: 5) { cards in
            StatefulPreviewWrapper(0) { selectedIndex in
                StereoGalleryStrip(
                    cards: cards,
                    selectedIndex: selectedIndex,
                    onSelectionChanged: { card in
                        print("Selected card: \(card.uuid)")
                    }
                )
                .padding()
            }
        }
    }

    // Helper for stateful previews
    private struct StatefulPreviewWrapper<Value, Content: View>: View {
        @State private var value: Value
        let content: (Binding<Value>) -> Content

        init(_ value: Value, content: @escaping (Binding<Value>) -> Content) {
            self._value = State(initialValue: value)
            self.content = content
        }

        var body: some View {
            content($value)
        }
    }

#endif
