//
//  CardListView.swift
//  Retroview
//
//  Created by Adam Schuster on 4/28/24.
//

import SwiftUI

struct CardListView: View {
    
    let cards: [CardSchemaV1.StereoCard]
    
    @Environment(\.modelContext) private var context
    
    var body: some View {
        List {
            ForEach(cards) { card in
                NavigationLink(value: card) {
                    HStack {
                        Text(card.uuid)
                        Spacer()
                        Text(card.titles.description)
                    }
                }
            }
        }
    }
}

#Preview {
    CardListView(cards: [])
        .modelContainer(for: [CardSchemaV1.StereoCard.self])
}
