//
//  CardGridView.swift
//  Retroview
//
//  Created by Adam Schuster on 6/9/24.
//

import SwiftUI
import SwiftData

struct CardGridView: View {
    let cards: [CardSchemaV1.StereoCard]
    
    @ObservedObject var viewModel = ImportViewModel()
    @Environment(\.modelContext) private var context
    

    @State private var isImporting = false
    
    var body: some View {
        let columns = [GridItem(.fixed(650), spacing: 10), GridItem(.fixed(650), spacing: 10)]
        
        ScrollView{
            LazyVGrid(columns: columns) {
                ForEach(cards) { card in
                    NavigationLink(destination: CardDetailView(card: card)) {
                        CardView(card: card)
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
