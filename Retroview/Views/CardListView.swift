//
//  CardListView.swift
//  Retroview
//
//  Created by Adam Schuster on 4/28/24.
//

import SwiftUI
import SwiftData

struct CardListView: View {
    let cards: [CardSchemaV1.StereoCard]
    
    @Environment(\.modelContext) private var context
    
    var body: some View {
        List {
            ForEach(cards) { card in
                NavigationLink(value: card) {
                    CardView(card: card)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        CardListView(cards: SampleData.shared.cards)
    }
    .modelContainer(SampleData.shared.modelContainer)
}
