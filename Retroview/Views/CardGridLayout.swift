//
//  CardGridGroup.swift
//  Retroview
//
//  Created by Adam Schuster on 12/20/24.
//

import SwiftData
import SwiftUI

struct CardGridLayout: View {
    let cards: [CardSchemaV1.StereoCard]
    @Binding var selectedCard: CardSchemaV1.StereoCard?
    let onCardSelected: (CardSchemaV1.StereoCard) -> Void
    
    private let columns = [
        GridItem(.adaptive(minimum: 300, maximum: 400), spacing: 20)
    ]
    
    var body: some View {
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
