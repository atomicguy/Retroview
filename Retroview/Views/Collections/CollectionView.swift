//
//  CollectionView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/9/24.
//

import SwiftData
import SwiftUI

struct CollectionView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: CollectionViewModel
    @State private var selectedCard: CardSchemaV1.StereoCard?
    
    init(collection: CollectionSchemaV1.Collection) {
        _viewModel = State(initialValue: CollectionViewModel(
            collection: collection,
            modelContext: ModelContext.shared
        ))
    }
    
    var body: some View {
        HStack(spacing: 0) {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 250))], spacing: 16) {
                    ForEach(viewModel.cards) { card in
                        CardSquareView(card: card)
                            .onTapGesture {
                                selectedCard = card
                            }
                    }
                }
                .padding()
            }
            
            if let card = selectedCard {
                Divider()
                CardContentView(card: card)
                    .frame(width: 300)
            }
        }
    }
}
