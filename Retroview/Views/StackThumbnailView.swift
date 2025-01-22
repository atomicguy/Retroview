//
//  StackThumbnailView.swift
//  Retroview
//
//  Created by Adam Schuster on 1/19/25.
//

import SwiftUI

struct StackThumbnailView: View {
    let item: StackDisplayable

    private let cornerRadius: CGFloat = 12
    private let titleHeight: CGFloat = 44
    private let cardPadding: CGFloat = 8
    private let maxStackedCards = 5

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Background with material
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(.ultraThinMaterial)
                    .background(
                        Color.accentColor.opacity(0.2)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    )

                // Card stack content
                cardStackContent(in: geometry)

                // Title bar
                titleBar

                // Card count badge
                cardCountBadge
                    .padding(12)
            }
            .aspectRatio(1, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            .shadow(radius: 2)
            .platformHover()
            .help(item.stackTitle)
        }
    }

    private var cardCountBadge: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: 32, height: 32)

            Text("\(item.stackCards.count)")
                .foregroundStyle(Color.black.opacity(0.8))
                .modifier(SerifFontModifier())
        }
        .frame(
            maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing
        )
        .offset(x: 8, y: -8)
    }

    @ViewBuilder
    private func cardStackContent(in geometry: GeometryProxy) -> some View {
        let cards = Array(item.stackCards.prefix(maxStackedCards))
        let availableHeight =
            geometry.size.height - titleHeight - (cardPadding * 2)
        let availableWidth = geometry.size.width - (cardPadding * 2)

        Group {
            if cards.isEmpty {
                Image(systemName: "photo.stack")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
                    .frame(
                        maxWidth: .infinity,
                        maxHeight: availableHeight + titleHeight
                    )
                    .offset(y: (-availableHeight / 6))
            } else {
                ZStack(alignment: .top) {
                    ForEach(Array(cards.enumerated()), id: \.element.id) {
                        index, card in
                        ThumbnailView(card: card)
                            .frame(width: availableWidth)
                            .offset(
                                y: calculateOffset(
                                    index: index,
                                    totalCards: cards.count,
                                    height: availableHeight)
                            )
                            .zIndex(Double(index))
                    }
                }
                .frame(height: availableHeight, alignment: .top)
                .padding(.bottom, titleHeight)
            }
        }
        .padding(cardPadding)
    }

    private func calculateOffset(index: Int, totalCards: Int, height: CGFloat)
        -> CGFloat
    {
        let cardHeight = (height - (2 * cardPadding)) / CGFloat(totalCards)

        guard totalCards > 1 else {
            return (height / 6)
        }

        return (cardHeight * CGFloat(index))

    }

    private var titleBar: some View {
        ZStack {
            // Dark glass background with gradient
            Rectangle()
                .fill(.ultraThinMaterial)
                .background(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.3), Color.black.opacity(0.9),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            // Title text with gold etched effect
            Text(item.stackTitle)
                .font(.system(.body, design: .serif))
                .foregroundStyle(
                    .linearGradient(
                        colors: [
                            Color(red: 0.9, green: 0.8, blue: 0.5),  // Light gold
                            Color(red: 0.6, green: 0.5, blue: 0.3),  // Darker gold
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
        }
        .frame(height: titleHeight)
    }
}

#if DEBUG
    import SwiftData

    struct StackThumbnailPreviewLayout: View {
        let stacks: [CollectionSchemaV1.Collection]

        var body: some View {
            ScrollView {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 200, maximum: 200))],
                    spacing: 20
                ) {
                    ForEach(Array(stacks.enumerated()), id: \.offset) {
                        index, stack in
                        VStack {
                            Text("\(stack.orderedCards.count) Cards")
                                .font(.caption)

                            StackThumbnailView(item: stack)
                                .aspectRatio(1, contentMode: .fit)
                        }
                    }
                }
                .padding()
            }
        }
    }

    struct StackThumbnailView_Previews: PreviewProvider {
        static var previews: some View {
            CardPreviewContainer { card in
                let container = try! PreviewDataManager.shared.container()
                let context = container.mainContext

                // Create collections with 0 to 5 cards
                let stacks = (0...5).map { count in
                    let collection = CollectionSchemaV1.Collection(
                        name: "\(count) Card Collection")
                    context.insert(collection)

                    // Add cards if needed
                    if count > 0 {
                        collection.addCard(card, context: context)

                        // Add additional cards if needed
                        if count > 1 {
                            let descriptor = FetchDescriptor<
                                CardSchemaV1.StereoCard
                            >()
                            if let cards = try? context.fetch(descriptor) {
                                for additionalCard in cards.prefix(count - 1) {
                                    if additionalCard.id != card.id {
                                        collection.addCard(
                                            additionalCard, context: context)
                                    }
                                }
                            }
                        }
                    }

                    return collection
                }

                try? context.save()

                return StackThumbnailPreviewLayout(stacks: stacks)
                    .withPreviewStore()
                    .environment(\.imageLoader, CardImageLoader())
                    .previewDisplayName("Stack Thumbnail Examples")
                    .frame(width: 1024, height: 800)
            }
        }
    }
#endif
