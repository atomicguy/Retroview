//
//  SquareCropGridView.swift
//  Retroview
//
//  Created by Adam Schuster on 11/26/24.
//

import SwiftData
import SwiftUI

struct SquareCropGridView: View {
    let cards: [CardSchemaV1.StereoCard]
    @Binding var selectedCard: CardSchemaV1.StereoCard?

    private let columns = [
        GridItem(.adaptive(minimum: 250, maximum: 300), spacing: 10),
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: columns,
                alignment: .center,
                spacing: 10
            ) {
                ForEach(cards) { card in
                    SquareCropView(card: card)
                        .contentShape(Rectangle())
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
        }
        .padding(16)
    }
}

// MARK: - Preview Provider

struct SquareCropGridView_Previews: PreviewProvider {
    static var previews: some View {
        CardsPreviewContainer { cards in
            SquareCropGridView(
                cards: cards,
                selectedCard: .constant(nil)
            )
            .frame(width: 800, height: 600)
        }
    }
}
