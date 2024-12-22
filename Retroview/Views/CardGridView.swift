//
//  CardGridGroup.swift
//  Retroview
//
//  Created by Adam Schuster on 12/20/24.
//

import SwiftData
import SwiftUI

struct CardGridView: View {
    @Query private var cards: [CardSchemaV1.StereoCard]
    @Binding var selectedCard: CardSchemaV1.StereoCard?
    let onCardSelected: (CardSchemaV1.StereoCard) -> Void
    
    init(
        sortBy: SortDescriptor<CardSchemaV1.StereoCard> = SortDescriptor(\.uuid),
        selectedCard: Binding<CardSchemaV1.StereoCard?>,
        onCardSelected: @escaping (CardSchemaV1.StereoCard) -> Void
    ) {
        _cards = Query(sort: [sortBy])
        _selectedCard = selectedCard
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
