//
//  CollectionContextMenu.swift
//  Retroview
//
//  Created by Adam Schuster on 11/28/24.
//

import SwiftData
import SwiftUI

struct CollectionContextMenu: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CollectionSchemaV1.Collection.name) private var collections:
        [CollectionSchemaV1.Collection]
    @Binding var showNewCollectionSheet: Bool

    let card: CardSchemaV1.StereoCard
    let currentCollection: CollectionSchemaV1.Collection?

    var body: some View {
        Group {
            if let collection = currentCollection {
                RemoveFromCollectionButton(collection: collection, card: card)
                Divider()
            }

            CollectionToggleSection(
                collections: collections, currentCollection: currentCollection,
                card: card
            )

            AddToNewCollectionButton(
                showNewCollectionSheet: $showNewCollectionSheet, card: card
            )
        }
    }
}

private struct RemoveFromCollectionButton: View {
    @Environment(\.modelContext) private var modelContext
    let collection: CollectionSchemaV1.Collection
    let card: CardSchemaV1.StereoCard

    var body: some View {
        Button(role: .destructive) {
            collection.removeCard(card)
            try? modelContext.save()
        } label: {
            Label("Remove from Collection", systemImage: "minus.circle")
        }
    }
}

private struct CollectionToggleSection: View {
    @Environment(\.modelContext) private var modelContext
    let collections: [CollectionSchemaV1.Collection]
    let currentCollection: CollectionSchemaV1.Collection?
    let card: CardSchemaV1.StereoCard

    var body: some View {
        ForEach(collections) { collection in
            if collection.id != currentCollection?.id {
                CollectionToggleButton(collection: collection, card: card)
            }
        }

        if !collections.isEmpty {
            Divider()
        }
    }
}

private struct CollectionToggleButton: View {
    @Environment(\.modelContext) private var modelContext
    let collection: CollectionSchemaV1.Collection
    let card: CardSchemaV1.StereoCard

    var body: some View {
        Button {
            toggleCard(in: collection)
        } label: {
            if collection.hasCard(card) {
                Label(collection.name, systemImage: "checkmark.circle.fill")
            } else {
                Label(collection.name, systemImage: "circle")
            }
        }
    }

    private func toggleCard(in collection: CollectionSchemaV1.Collection) {
        if collection.hasCard(card) {
            collection.removeCard(card)
        } else {
            collection.addCard(card)
        }
        try? modelContext.save()
    }
}

private struct AddToNewCollectionButton: View {
    @Binding var showNewCollectionSheet: Bool
    let card: CardSchemaV1.StereoCard

    var body: some View {
        Button {
            showNewCollectionSheet = true
        } label: {
            Label("New Collection...", systemImage: "folder.badge.plus")
        }
    }
}

#Preview {
    CardPreviewContainer { card in
        Text("Right click to see menu")
            .contextMenu {
                CollectionContextMenu(
                    showNewCollectionSheet: .constant(false),
                    card: card,
                    currentCollection: PreviewContainer.shared.modelContainer.mainContext.collectionSampleData()
                )
            }
    }
}
