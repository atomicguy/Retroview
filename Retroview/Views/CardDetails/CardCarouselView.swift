//
//  CardCarouselView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/31/24.
//

import SwiftData
import SwiftUI

struct CardCarouselView: View {
    let cards: [CardSchemaV1.StereoCard]
    let initialCard: CardSchemaV1.StereoCard
    @State private var currentCard: CardSchemaV1.StereoCard

    init(cards: [CardSchemaV1.StereoCard], initialCard: CardSchemaV1.StereoCard)
    {
        self.cards = cards
        self.initialCard = initialCard
        _currentCard = State(initialValue: initialCard)
    }

    var body: some View {
        HorizontalCardStrip(cards: cards, initialCard: initialCard) { index in
            currentCard = cards[index]
        }
        .platformNavigationTitle(
            currentCard.titlePick?.text ?? "Untitled Card",
            subtitle: currentCard.authors.map(\.name).first,
            displayMode: .inline
        )
        .platformToolbar {
            EmptyView()
        } trailing: {
            HStack {
                #if !os(visionOS)
                    CardShareButton(card: currentCard)
                    CardActionMenu.asButton(card: currentCard)
                #else
                    CardActionMenu.asButton(
                        card: currentCard, includeShare: true)
                #endif
            }
        }
    }
}

#Preview("Card Detail Stack View") {
    NavigationStack {
        CardsPreviewContainer(count: 5) { cards in
            CardCarouselView(
                cards: cards,
                initialCard: cards[cards.count / 2]
            )
            .environment(\.imageLoader, CardImageLoader())
        }
    }
}
