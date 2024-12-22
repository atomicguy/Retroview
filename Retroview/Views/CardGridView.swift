//
//  CardGridGroup.swift
//  Retroview
//
//  Created by Adam Schuster on 12/20/24.
//

import SwiftData
import SwiftUI

struct CardGridView: View {
    let cards: [CardSchemaV1.StereoCard]
    @Binding var selectedCard: CardSchemaV1.StereoCard?
    let onCardSelected: (CardSchemaV1.StereoCard) -> Void
    
    init(
        cards: [CardSchemaV1.StereoCard],
        selectedCard: Binding<CardSchemaV1.StereoCard?>,
        onCardSelected: @escaping (CardSchemaV1.StereoCard) -> Void
    ) {
        self.cards = cards
        self._selectedCard = selectedCard
        self.onCardSelected = onCardSelected
    }
    
    var body: some View {
        SharedCardGridView(
            cards: cards,
            selectedCard: $selectedCard,
            onCardSelected: onCardSelected,
            emptyContentTitle: "No Cards",
            emptyContentDescription: "This library is empty"
        )
    }
}
