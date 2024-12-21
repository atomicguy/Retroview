//
//  CollectionView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/20/24.
//

import SwiftUI
import SwiftData

struct CollectionView: View {
    @Bindable var collection: CollectionSchemaV1.Collection
    @State private var selectedCard: CardSchemaV1.StereoCard?
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            CardGridView(
                cards: collection.orderedCards,
                selectedCard: $selectedCard,
                onCardSelected: { card in navigationPath.append(card) }
            )
            .navigationTitle(collection.name)
            .navigationDestination(for: CardSchemaV1.StereoCard.self) { card in
                CardDetailView(card: card)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(role: .destructive) {
                            collection.cards.removeAll()
                        } label: {
                            Label("Clear Collection", systemImage: "trash")
                        }
                    } label: {
                        Label("More", systemImage: "ellipsis.circle")
                    }
                }
            }
        }
    }
}
