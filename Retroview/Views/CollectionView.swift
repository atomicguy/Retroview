//
//  CollectionView.swift
//  Retroview
//
//  Created by Adam Schuster on 11/27/24.
//

import SwiftUI
import SwiftData

struct CollectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var collection: CollectionSchemaV1.Collection
    @State private var selectedCard: CardSchemaV1.StereoCard?
    @State private var cards: [CardSchemaV1.StereoCard] = []
    @State private var showingAddCards = false
    
    // Fixed width for details panel
    private let detailWidth: CGFloat = 300
    
    var body: some View {
        HStack(spacing: 0) {
            ReorderableCardGridView(
                cards: $cards,
                selectedCard: $selectedCard
            ) { newOrder in
                collection.updateCards(newOrder)
                try? modelContext.save()
            }
            .frame(maxWidth: .infinity)
            
            Divider()
            
            Group {
                if let card = selectedCard {
                    CardContentView(card: card)
                        .id(card.uuid)
                } else {
                    ContentUnavailableView(
                        "No Card Selected",
                        systemImage: "photo.on.rectangle",
                        description: Text("Select a card to view its details")
                    )
                }
            }
            .frame(width: detailWidth)
        }
        .navigationTitle(collection.name)
        .onAppear {
            refreshCards()
        }
        .toolbar {
            ToolbarItem {
                Button {
                    showingAddCards = true
                } label: {
                    Label("Add Cards", systemImage: "plus")
                }
            }
        }
    }
    
    private func refreshCards() {
        cards = collection.fetchCards(context: modelContext)
    }
}
