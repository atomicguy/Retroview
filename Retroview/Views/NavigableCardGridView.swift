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
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
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
                            navigationPath.append(card)
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
}
