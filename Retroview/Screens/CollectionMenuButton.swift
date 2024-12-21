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
    @Query(sort: \CollectionSchemaV1.Collection.name) private var collections: [CollectionSchemaV1.Collection]
    
    let card: CardSchemaV1.StereoCard
    @State private var showingCollectionSheet = false
    
    var body: some View {
        Menu {
            if collections.isEmpty {
                Text("No collections")
            } else {
                CollectionsSection(
                    collections: collections.filter { !CollectionDefaults.isFavorites($0) },
                    card: card
                )
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
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showingCollectionSheet) {
            CollectionCreationView(card: card)
        }
    }
}

private struct CollectionsSection: View {
    let collections: [CollectionSchemaV1.Collection]
    let card: CardSchemaV1.StereoCard
    
    var body: some View {
        // First show collections that contain the card
        ForEach(collections.filter { $0.hasCard(card) }) { collection in
            CollectionToggleButton(collection: collection, card: card, containsCard: true)
        }
        
        // Then show collections that don't contain the card
        let remainingCollections = collections.filter { !$0.hasCard(card) }
        if !remainingCollections.isEmpty && !collections.filter({ $0.hasCard(card) }).isEmpty {
            Divider()
        }
        
        ForEach(remainingCollections) { collection in
            CollectionToggleButton(collection: collection, card: card, containsCard: false)
        }
    }
}

private struct CollectionToggleButton: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var collection: CollectionSchemaV1.Collection
    let card: CardSchemaV1.StereoCard
    let containsCard: Bool
    
    var body: some View {
        Button {
            toggleCardInCollection()
        } label: {
            HStack {
                Image(systemName: containsCard ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(containsCard ? .primary : .secondary)
                Text(collection.name)
                    .foregroundStyle(.primary)
            }
        }
        .buttonStyle(.plain) // Ensure consistent button style across platforms
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

struct CollectionCreationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let card: CardSchemaV1.StereoCard
    @State private var collectionName = ""
    @FocusState private var isNameFieldFocused: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Collection Name", text: $collectionName)
                    .focused($isNameFieldFocused)
                    .textFieldStyle(.roundedBorder)
            }
            .navigationTitle("New Collection")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createCollection()
                    }
                    .disabled(collectionName.isEmpty)
                }
            }
        }
    }
    
    private func createCollection() {
        let collection = CollectionSchemaV1.Collection(name: collectionName.trimmingCharacters(in: .whitespaces))
        collection.addCard(card)
        modelContext.insert(collection)
        try? modelContext.save()
        dismiss()
    }
}
