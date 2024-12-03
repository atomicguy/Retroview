//
//  CardCollectionGrid.swift
//  Retroview
//
//  Created by Adam Schuster on 12/2/24.
//

import SwiftUI

struct CardCollectionGrid: View {
    let cards: [CardSchemaV1.StereoCard]
    @Binding var selectedCard: CardSchemaV1.StereoCard?

    private let columns = [
        GridItem(.adaptive(minimum: 250, maximum: 300), spacing: 10),
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(cards) { card in
                    CardSquareView(card: card)
                        .onTapGesture {
                            selectedCard = card
                        }
                        .overlay {
                            if selectedCard?.uuid == card.uuid {
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.accentColor, lineWidth: 3)
                            }
                        }
                }
            }
            .padding()
        }
    }
}

#Preview("Card Collection Grid") {
    CardsPreviewContainer { cards in
        CardCollectionGrid(
            cards: cards,
            selectedCard: .constant(cards.first)
        )
        .frame(width: 1200, height: 800)
    }
}
