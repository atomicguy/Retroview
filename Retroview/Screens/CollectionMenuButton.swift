//
//  CollectionMenuButton.swift
//  Retroview
//
//  Created by Adam Schuster on 12/19/24.
//

import SwiftUI
import SwiftData

struct CollectionMenuButton: View {
    @Environment(\.modelContext) private var modelContext
    let card: CardSchemaV1.StereoCard
    @Binding var showingNewCollectionSheet: Bool
    @State private var collections: [CollectionSchemaV1.Collection] = []
    @State private var cardCollectionIds: Set<UUID> = []
    
    var body: some View {
        Menu {
            if collections.isEmpty {
                Text("No collections")
            } else {
                ForEach(collections) { collection in
                    if !CollectionDefaults.isFavorites(collection) {
                        Button {
                            Task {
                                await toggleCollection(collection)
                            }
                        } label: {
                            Label(
                                collection.name,
                                systemImage: cardCollectionIds.contains(collection.id) ? "checkmark.circle.fill" : "circle"
                            )
                        }
                    }
                }
                Divider()
            }
            
            Button {
                showingNewCollectionSheet = true
            } label: {
                Label("New Collection...", systemImage: "folder.badge.plus")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .font(.title2)
                .foregroundStyle(.white)
                .shadow(radius: 2)
        }
        .task {
            await loadCollections()
        }
    }
    
    private func loadCollections() async {
        let descriptor = FetchDescriptor<CollectionSchemaV1.Collection>(
            sortBy: [SortDescriptor(\.name)]
        )
        
        if let fetchedCollections = try? modelContext.fetch(descriptor) {
            collections = fetchedCollections
            cardCollectionIds = Set(fetchedCollections.filter { $0.hasCard(card) }.map(\.id))
        }
    }
    
    private func toggleCollection(_ collection: CollectionSchemaV1.Collection) async {
        if cardCollectionIds.contains(collection.id) {
            collection.removeCard(card)
            cardCollectionIds.remove(collection.id)
        } else {
            collection.addCard(card)
            cardCollectionIds.insert(collection.id)
        }
        try? modelContext.save()
    }
}

private struct CollectionToggleButton: View {
    @Environment(\.modelContext) private var modelContext
    let collection: CollectionSchemaV1.Collection
    let card: CardSchemaV1.StereoCard
    
    var body: some View {
        Button {
            toggleCardInCollection()
        } label: {
            Label(
                collection.name,
                systemImage: collection.hasCard(card) ? "checkmark.circle.fill" : "circle"
            )
        }
    }
    
    private func toggleCardInCollection() {
        if collection.hasCard(card) {
            collection.removeCard(card)
        } else {
            collection.addCard(card)
        }
        try? modelContext.save()
    }
}
