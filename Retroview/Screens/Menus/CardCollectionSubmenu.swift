//
//  CardCollectionSubmenu.swift
//  Retroview
//
//  Created by Adam Schuster on 1/1/25.
//

import SwiftData
import SwiftUI

struct CardCollectionSubmenu: View {
    @Environment(\.modelContext) private var modelContext
    @Query(
        filter: #Predicate<CollectionSchemaV1.Collection> { collection in
            collection.name != "Favorites"
        },
        sort: \.name
    ) private var collections: [CollectionSchemaV1.Collection]

    let card: CardSchemaV1.StereoCard
    @Binding var showingCollectionSheet: Bool

    var body: some View {
        if collections.isEmpty {
            Text("No collections")
        } else {
            ForEach(collections) { collection in
                CollectionToggleButton(collection: collection, card: card)
            }
            Divider()
        }

        Button {
            showingCollectionSheet = true
        } label: {
            HStack {
                Image(systemName: "folder.badge.plus")
                Text("New Collection...")
            }
        }
    }
}

private struct CollectionToggleButton: View {
    @Environment(\.modelContext) private var modelContext
    let collection: CollectionSchemaV1.Collection
    let card: CardSchemaV1.StereoCard

    var body: some View {
        Button {
            if collection.hasCard(card) {
                collection.removeCard(card, context: modelContext)
            } else {
                collection.addCard(card, context: modelContext)
            }
            try? modelContext.save()
        } label: {
            HStack {
                Image(
                    systemName: collection.hasCard(card)
                        ? "checkmark.circle.fill" : "circle"
                )
                .foregroundStyle(
                    collection.hasCard(card) ? .primary : .secondary)
                Text(collection.name)
            }
        }
    }
}

#Preview {
    CardPreviewContainer { card in
        CardCollectionSubmenu(
            card: card,
            showingCollectionSheet: .constant(false)
        )
    }
}
