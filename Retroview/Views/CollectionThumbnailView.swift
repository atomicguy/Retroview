//
//  CollectionThumbnailView.swift
//  Retroview
//
//  Created by Adam Schuster on 1/5/25.
//

import SwiftData
import SwiftUI

#if os(macOS)
    import AppKit
    typealias PlatformImage = NSImage
#else
    import UIKit
    typealias PlatformImage = UIImage
#endif

struct CollectionThumbnailView: View {
    let collection: CollectionSchemaV1.Collection
    let maxStackedCards = 5
    private let textOverlayHeight = CGFloat(44)
    private let cardPadding: CGFloat = 8  // Padding around the cards

    var body: some View {
        ZStack(alignment: .bottom) {
            // Background with ultra-thin material and accent tint
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .background(
                    Color.accentColor.opacity(0.2)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                )

            // Card thumbnails
            thumbnailContent
                .clipped()

            // Title overlay at the bottom
            textOverlay
        }
        .aspectRatio(1, contentMode: .fit)  // Ensure the entire thumbnail remains a square
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .platformInteraction(
            InteractionConfig(
                showHoverEffects: true
            )
        )
    }

    private var thumbnailContent: some View {
        GeometryReader { geometry in
            let size = geometry.size.width  // Use width to define the square size

            dynamicCardStack(in: geometry)
                .frame(width: size, height: size)  // Force a square frame
                .clipped()  // Ensure no overflow outside the bounds
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private var dynamicThumbnailView: some View {
        GeometryReader { geometry in
            dynamicCardStack(in: geometry)
        }
    }

    private func cachedThumbnailView(image: PlatformImage) -> some View {
        #if os(macOS)
            return Image(nsImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        #else
            return Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        #endif
    }

    private func dynamicCardStack(in geometry: GeometryProxy) -> some View {
        let size = geometry.size.width  // Use width for both width and height
        let visibleCards = Array(
            collection.orderedCards.prefix(maxStackedCards))
        let totalCards = visibleCards.count

        return ZStack(alignment: .top) {
            Color.clear
            ForEach(Array(visibleCards.enumerated()), id: \.element.id) {
                index, card in
                ThumbnailView(card: card)
                    .frame(width: size - (2 * cardPadding))
                    .aspectRatio(contentMode: .fit)
                    #if !os(visionOS)
                        .shadow(
                            color: Color.black.opacity(0.2), radius: 4, x: 0,
                            y: 2)
                    #endif
                    .offset(
                        y: calculateCardOffset(
                            index: index,
                            totalCards: totalCards,
                            availableHeight: size
                        )
                    )
            }
        }
    }

    private func calculateCardOffset(
        index: Int,
        totalCards: Int,
        availableHeight: CGFloat
    ) -> CGFloat {
        // Infer card height by dividing the effective height by the number of cards
        let cardHeight =
            (availableHeight - (2 * cardPadding) - textOverlayHeight)
            / CGFloat(totalCards)

        guard totalCards > 1 else {
            // Center a single card vertically, adding cardPadding to the top
            return ((availableHeight - textOverlayHeight) / 2) + cardPadding
                - cardHeight / 3
        }

        // The spacing between consecutive cards is equal to the inferred card height
        let cardSpacing = cardHeight

        // Calculate the offset for the given card index, adding cardPadding to shift the stack down
        return (cardSpacing * CGFloat(index)) + cardPadding
    }

    private func platformImage(from data: Data) -> PlatformImage? {
        PlatformImage(data: data)
    }

    private var textOverlay: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)

            LinearGradient(
                colors: [.clear, .black.opacity(0.5)],
                startPoint: .top,
                endPoint: .bottom
            )

            Text(collection.name)
                .serifFont()
                .lineLimit(1)
                .foregroundStyle(.primary)
                .padding(.vertical, 8)
        }
        .frame(height: textOverlayHeight)
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
