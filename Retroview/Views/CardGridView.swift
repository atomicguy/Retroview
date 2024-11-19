//
//  CardGridView.swift
//  Retroview
//
//  Created by Adam Schuster on 6/9/24.
//

import SwiftData
import SwiftUI

struct CardGridView: View {
    let cards: [CardSchemaV1.StereoCard]
    
    var body: some View {
        let columns = [
            GridItem(.fixed(650), spacing: 10),
            GridItem(.fixed(650), spacing: 10),
        ]
        
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(cards) { card in
                    NavigationLink(destination: CardDetailView(card: card)) {
                        UnifiedCardView(card: card, style: .grid)
                            .contentShape(.rect(cornerRadius: 20))
                            .aspectRatio(2, contentMode: .fit)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.regularMaterial)
                    .aspectRatio(2, contentMode: .fit)
                    .clipShape(.rect(cornerRadius: 20))
                    .padding(5)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    NavigationStack {
        CardGridView(cards: SampleData.shared.cards)
    }
    .modelContainer(SampleData.shared.modelContainer)
}
