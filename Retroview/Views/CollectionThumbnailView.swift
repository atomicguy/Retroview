//
//  CollectionThumbnailView.swift
//  Retroview
//
//  Created by Adam Schuster on 1/5/25.
//

import SwiftData
import SwiftUI

struct CollectionThumbnailView: View {
    let collection: CollectionSchemaV1.Collection
    private let maxStackedCards = 5
    private let textOverlayHeight = CGFloat(44)

    @State private var lastCardHeight: CGFloat? = nil

    var body: some View {
        ZStack {
            // Material overlay for depth
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)

            // Stacked cards with geometry scaling
            GeometryReader { geometry in
                if !collection.orderedCards.isEmpty {
                    let visibleCards = Array(
                        collection.orderedCards.prefix(maxStackedCards))
                    let availableSpace = geometry.size.height

                    ZStack {
                        ForEach(
                            Array(visibleCards.enumerated()), id: \.element.id
                        ) { index, card in
                            ThumbnailView(card: card)
                                .frame(width: geometry.size.width)
                                .background(
                                    GeometryReader { cardGeometry in
                                        Color.clear
                                            .preference(
                                                key: CardHeightPreferenceKey
                                                    .self,
                                                value: cardGeometry.size.height
                                            )
                                    }
                                )
                                .offset(
                                    y: calculateOffset(
                                        index: index,
                                        totalCards: visibleCards.count,
                                        availableSpace: availableSpace,
                                        lastCardHeight: lastCardHeight ?? 0
                                    ))
                        }
                    }
                    .onPreferenceChange(CardHeightPreferenceKey.self) {
                        height in
                        lastCardHeight = height
                    }
                } else {
                    Image(systemName: "photo.stack")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)

            // Text overlay with gradient background
            VStack {
                Spacer()
                ZStack {
                    // Ultra thin material overlay
                    Rectangle()
                        .fill(.ultraThinMaterial)

                    // Gradient behind material for better contrast
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.5)],
                        startPoint: .top,
                        endPoint: .bottom
                    )

                    // Text content
                    Text(collection.name)
                        .serifFont()
                        .lineLimit(1)
                        .foregroundStyle(.primary)
                        .padding(.vertical, 8)
                }
                .frame(height: textOverlayHeight)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .aspectRatio(1, contentMode: .fit)
    }

    private func calculateOffset(
        index: Int,
        totalCards: Int,
        availableSpace: CGFloat,
        lastCardHeight: CGFloat
    ) -> CGFloat {
        guard totalCards > 1 else {
            // Vertically center a single card
            let topSpace = availableSpace - textOverlayHeight
            return (topSpace / 2) - (lastCardHeight / 2)
        }

        if index == 0 {
            // Ensure the first card's top edge is at the top of the available space
            return 0
        }

        // Calculate the remaining space above the last card
        let remainingSpace = availableSpace - lastCardHeight
        let step = remainingSpace / CGFloat(totalCards - 1)

        // Offset cards evenly above the last card
        return step * CGFloat(index)
    }
}

struct CardHeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat? = nil

    static func reduce(value: inout CGFloat?, nextValue: () -> CGFloat?) {
        if let next = nextValue() {
            value = next
        }
    }
}

#Preview("Collection Thumbnails") {
    VStack(spacing: 12) {
        HStack(spacing: 12) {
            // Collection with 5 cards
            CardsPreviewContainer(count: 5) { cards in
                let collection = CollectionSchemaV1.Collection(
                    name: "Five Cards")
                cards.forEach { card in
                    collection.addCard(card, context: card.modelContext!)
                }
                return CollectionThumbnailView(collection: collection)
            }

            // Collection with 4 cards
            CardsPreviewContainer(count: 4) { cards in
                let collection = CollectionSchemaV1.Collection(
                    name: "Four Cards")
                cards.forEach { card in
                    collection.addCard(card, context: card.modelContext!)
                }
                return CollectionThumbnailView(collection: collection)
            }

            // Collection with 3 card
            CardsPreviewContainer(count: 3) { cards in
                let collection = CollectionSchemaV1.Collection(
                    name: "Three Cards")
                cards.forEach { card in
                    collection.addCard(card, context: card.modelContext!)
                }
                return CollectionThumbnailView(collection: collection)
            }
        }
        HStack(spacing: 12) {
            // Collection with 2 cards
            CardsPreviewContainer(count: 2) { cards in
                let collection = CollectionSchemaV1.Collection(
                    name: "Two Cards")
                cards.forEach { card in
                    collection.addCard(card, context: card.modelContext!)
                }
                return CollectionThumbnailView(collection: collection)
            }

            // Collection with 1 card
            CardsPreviewContainer(count: 1) { cards in
                let collection = CollectionSchemaV1.Collection(name: "One Card")
                cards.forEach { card in
                    collection.addCard(card, context: card.modelContext!)
                }
                return CollectionThumbnailView(collection: collection)
            }

            // Empty collection
            let emptyCollection = CollectionSchemaV1.Collection(name: "Empty")
            CollectionThumbnailView(collection: emptyCollection)
                .withPreviewStore()
        }
    }
    .frame(height: 500)
    .padding()
}
