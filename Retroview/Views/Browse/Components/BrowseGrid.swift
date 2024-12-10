//
//  BrowseGrid.swift
//  Retroview
//
//  Created by Adam Schuster on 12/9/24.
//

import SwiftUI

struct BrowseGrid: View {
    let cards: [CardSchemaV1.StereoCard]
    @Binding var selectedCard: CardSchemaV1.StereoCard?
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 250))], spacing: 16) {
                ForEach(cards) { card in
                    CardSquareView(card: card)
                        .onTapGesture {
                            selectedCard = card
                        }
                }
            }
            .padding()
        }
    }
}
