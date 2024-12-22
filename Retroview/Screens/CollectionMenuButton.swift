//
//  CollectionMenuButton.swift
//  Retroview
//
//  Created by Adam Schuster on 12/19/24.
//

import OSLog
import SwiftData
import SwiftUI

private let logger = Logger(
    subsystem: "com.example.retroview", category: "CollectionUI")

struct CollectionMenuButton: View {
    @Environment(\.modelContext) private var modelContext
    @Query(
        filter: #Predicate<CollectionSchemaV1.Collection> { collection in
            collection.name != "Favorites"
        },
        sort: \.name
    ) private var collections: [CollectionSchemaV1.Collection]

    let card: CardSchemaV1.StereoCard
    @State private var showingCollectionSheet = false

    var body: some View {
        Menu {
            if collections.isEmpty {
                Text("No collections")
            } else {
                ForEach(collections) { collection in
                    CollectionToggleButton(
                        collection: collection,
                        card: card
                    )
                }
                Divider()
            }

            Button {
                showingCollectionSheet = true
            } label: {
                Label("New Collection...", systemImage: "folder.badge.plus")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .font(.title2)
                .foregroundStyle(.white)
                .shadow(radius: 2)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingCollectionSheet) {
            CollectionCreationView(card: card)
        }
    }
}

private struct CollectionToggleButton: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var collection: CollectionSchemaV1.Collection
    let card: CardSchemaV1.StereoCard

    var body: some View {
        Button {
            Task {
                logger.debug(
                    "Toggle initiated for card \(card.uuid) in collection \(collection.name)"
                )
                if collection.hasCard(card) {
                    collection.removeCard(card, context: modelContext)
                } else {
                    collection.addCard(card, context: modelContext)
                }
            }
        } label: {
            HStack {
                Image(
                    systemName: collection.hasCard(card)
                        ? "checkmark.circle.fill" : "circle"
                )
                .foregroundStyle(
                    collection.hasCard(card) ? .primary : .secondary)
                Text(collection.name)
                    .foregroundStyle(.primary)
            }
        }
    }
}
