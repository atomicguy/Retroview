//
//  NavigableCardGridView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/22/24.
//

import SwiftData
import SwiftUI

struct NavigableCardGrid<Header: View>: View {
    let cards: [CardSchemaV1.StereoCard]
    let emptyTitle: String
    let emptyDescription: String
    @ViewBuilder let header: () -> Header
    
    @State private var selectedCard: CardSchemaV1.StereoCard?
    
    var body: some View {
        Group {
            if cards.isEmpty {
                ContentUnavailableView {
                    Label(emptyTitle, systemImage: "photo.on.rectangle.angled")
                } description: {
                    Text(emptyDescription)
                }
            } else {
                CardGridLayout(
                    cards: cards,
                    selectedCard: $selectedCard,
                    onCardSelected: { card in
                        // Let parent handle navigation by providing NavigationStack
                        selectedCard = card
                    }
                )
            }
        }
        .navigationDestination(for: CardSchemaV1.StereoCard.self) { card in
            CardDetailView(card: card)
                .platformNavigationTitle(card.titlePick?.text ?? "Card Details", displayMode: .inline)
        }
        header()
    }
}
