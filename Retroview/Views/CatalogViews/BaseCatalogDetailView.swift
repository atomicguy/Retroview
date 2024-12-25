//
//  CatalogDetailView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/22/24.
//

import SwiftData
import SwiftUI

struct BaseCatalogDetailView<Item: CatalogItem>: View {
    let item: Item
    @State private var selectedCard: CardSchemaV1.StereoCard?
    
    var body: some View {
        CardGridLayout(
            cards: item.cards,
            selectedCard: $selectedCard,
            onCardSelected: { card in
                selectedCard = card
            }
        )
        .navigationTitle(item.name)
    }
}
