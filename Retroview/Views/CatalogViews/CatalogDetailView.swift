//
//  CatalogDetailView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/22/24.
//

import SwiftData
import SwiftUI

struct CatalogDetailView<Item: CatalogItem>: View {
    let item: Item
    @State private var selectedCard: CardSchemaV1.StereoCard?
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            NavigableCardGrid(
                cards: item.cards,
                emptyTitle: "No Cards",
                emptyDescription: "No cards found"
            ) {
                EmptyView()
            }
            .navigationTitle(item.name)
            .navigationDestination(for: CardSchemaV1.StereoCard.self) { card in
                CardDetailView(card: card)
                    .platformNavigationTitle(
                        card.titlePick?.text ?? "Card Details",
                        displayMode: .inline)
            }
        }
    }
}
