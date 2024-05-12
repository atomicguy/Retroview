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
//    let titles: [TitleSchemaV1.Title]
    
    @Environment(\.modelContext) private var context
    
    var body: some View {
        List {
            ForEach(cards) { card in
                NavigationLink(value: card) {
                    HStack {
                        Text(card.uuid)
                        Spacer()
                        VStack(alignment: .leading) {
                            if card.titles.count > 0 {
                                ForEach(0 ..< card.titles.count, id: \.self) { index in
                                    Text(card.titles[index].text)
                                }
                            }
                        }
                    }
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
