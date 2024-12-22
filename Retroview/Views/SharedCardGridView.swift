//
//  SharedCardView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/22/24.
//

import SwiftUI
import SwiftData

struct SharedCardGridView: View {
    @Binding var selectedCard: CardSchemaV1.StereoCard?
    let cards: [CardSchemaV1.StereoCard]
    let onCardSelected: (CardSchemaV1.StereoCard) -> Void
    let emptyContentTitle: String
    let emptyContentDescription: String
    
    private let columns = [
        GridItem(.adaptive(minimum: 300, maximum: 400), spacing: 20)
    ]
    
    init(
        cards: [CardSchemaV1.StereoCard],
        selectedCard: Binding<CardSchemaV1.StereoCard?>,
        onCardSelected: @escaping (CardSchemaV1.StereoCard) -> Void,
        emptyContentTitle: String = "No Cards",
        emptyContentDescription: String = "No cards to display"
    ) {
        self.cards = cards
        self._selectedCard = selectedCard
        self.onCardSelected = onCardSelected
        self.emptyContentTitle = emptyContentTitle
        self.emptyContentDescription = emptyContentDescription
    }
    
    var body: some View {
        if cards.isEmpty {
            ContentUnavailableView {
                Label(emptyContentTitle, systemImage: "photo.on.rectangle.angled")
            } description: {
                Text(emptyContentDescription)
            }
        } else {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(cards) { card in
                        SelectableThumbnailView(
                            card: card,
                            isSelected: card.id == selectedCard?.id,
                            onSelect: { selectedCard = card },
                            onDoubleClick: { onCardSelected(card) }
                        )
                    }
                }
                .padding()
            }
        }
    }
}
