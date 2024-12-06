//
//  CollectionMenuView.swift
//  Retroview
//
//  Created by Adam Schuster on 11/28/24.
//

import SwiftData
import SwiftUI

struct CollectionMenuContent: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CollectionSchemaV1.Collection.name) private var collections:
        [CollectionSchemaV1.Collection]
    @Binding var showNewCollectionSheet: Bool

    let card: CardSchemaV1.StereoCard
    let currentCollection: CollectionSchemaV1.Collection?

    var body: some View {
        if let collection = currentCollection {
            Button(role: .destructive) {
                collection.removeCard(card)
                try? modelContext.save()
            } label: {
                Label("Remove from Collection", systemImage: "minus.circle")
            }

            Divider()
        }

        ForEach(collections) { collection in
            if collection.id != currentCollection?.id {
                Button {
                    toggleCard(in: collection)
                } label: {
                    if collection.hasCard(card) {
                        Label(
                            collection.name,
                            systemImage: "checkmark.circle.fill"
                        )
                    } else {
                        Label(collection.name, systemImage: "circle")
                    }
                }
            }
        }

        if !collections.isEmpty {
            Divider()
        }

        Button {
            showNewCollectionSheet = true
        } label: {
            Label("New Collection...", systemImage: "folder.badge.plus")
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

// MARK: - Menu Wrapper Views

struct CollectionContextMenu: View {
    @Binding var showNewCollectionSheet: Bool
    let card: CardSchemaV1.StereoCard
    let currentCollection: CollectionSchemaV1.Collection?

    var body: some View {
        CollectionMenuContent(
            showNewCollectionSheet: $showNewCollectionSheet,
            card: card,
            currentCollection: currentCollection
        )
    }
}

#Preview("Collection Menu - No Collection") {
    CardPreviewContainer { card in
        Menu {
            CollectionMenuContent(
                showNewCollectionSheet: .constant(false),
                card: card,
                currentCollection: nil
            )
        } label: {
            Text("Open Menu")
                .font(.system(.body, design: .serif))
        }
    }
}

#Preview("Collection Menu - In Collection") {
    CardPreviewContainer { card in
        Menu {
            CollectionMenuContent(
                showNewCollectionSheet: .constant(false),
                card: card,
                currentCollection: CollectionSchemaV1.Collection.preview
            )
        } label: {
            Text("Open Menu")
        }
    }
}
