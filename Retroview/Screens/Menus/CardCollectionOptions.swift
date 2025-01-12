//
//  CardCollectionOptions.swift
//  Retroview
//
//  Created by Adam Schuster on 1/9/25.
//

import SwiftData
import SwiftUI

struct CardCollectionOptions: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.createCollection) private var createCollection
    @Query(
        filter: #Predicate<CollectionSchemaV1.Collection> {
            $0.name != "Favorites"
        },
        sort: \.name
    ) private var collections: [CollectionSchemaV1.Collection]

    let card: CardSchemaV1.StereoCard
    @Binding var showNewCollectionSheet: Bool

    var body: some View {
        Group {
            ForEach(collections) { collection in
                Button {
                    toggleCollection(collection)
                } label: {
                    Label(
                        collection.name,
                        systemImage: collection.hasCard(card)
                            ? "checkmark.circle.fill"
                            : "circle")
                }
            }

            if !collections.isEmpty {
                Divider()
            }

            Button {
                createNewCollection()
            } label: {
                Label("New Collection...", systemImage: "folder.badge.plus")
            }
        }
    }

    private func createNewCollection() {
        createCollection?(card)
    }

    private func toggleCollection(_ collection: CollectionSchemaV1.Collection) {
        if collection.hasCard(card) {
            collection.removeCard(card, context: modelContext)
        } else {
            collection.addCard(card, context: modelContext)
        }
        try? modelContext.save()
    }
}
