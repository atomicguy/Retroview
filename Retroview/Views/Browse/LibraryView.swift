//
//  LibraryView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/9/24.
//

import SwiftData
import SwiftUI

struct LibraryView: View {
    @Query private var cards: [CardSchemaV1.StereoCard]
    @State private var selectedCard: CardSchemaV1.StereoCard?
    
    var body: some View {
        HStack(spacing: 0) {
            BrowseGrid(cards: cards, selectedCard: $selectedCard)
            
            if let card = selectedCard {
                Divider()
                CardContentView(card: card)
                    .frame(width: 300)
            }
        }
    }
}
