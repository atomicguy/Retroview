//
//  CollectionView.swift
//  Retroview
//
//  Created by Adam Schuster on 11/27/24.
//

import SwiftData
import SwiftUI

struct CollectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var collection: CollectionSchemaV1.Collection
    @State private var selectedCard: CardSchemaV1.StereoCard?
    @State private var showingAddCards = false

    // Query cards based on the collection's cardUUIDs
    var cards: [CardSchemaV1.StereoCard] {
        let uuids = collection.cardUUIDs.compactMap { UUID(uuidString: $0) }
        let descriptor = FetchDescriptor<CardSchemaV1.StereoCard>(
            predicate: #Predicate<CardSchemaV1.StereoCard> { card in
                uuids.contains(card.uuid)
            }
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    // Fixed width for details panel
    private let detailWidth: CGFloat = 300

    var body: some View {
        HStack(spacing: 0) {
            ReorderableCardGridView(
                cards: .constant(
                    cards.sorted { first, second in
                        // Sort based on the collection's cardOrder
                        guard
                            let firstIndex = collection.cardUUIDs.firstIndex(
                                of: first.uuid.uuidString),
                            let secondIndex = collection.cardUUIDs.firstIndex(
                                of: second.uuid.uuidString)
                        else {
                            return false
                        }
                        return firstIndex < secondIndex
                    }),
                selectedCard: $selectedCard)
            { newOrder in
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
                        description: Text("Select a card to view its details"))
                }
            }
            .frame(width: detailWidth)
        }
        .navigationTitle(collection.name)
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
}
