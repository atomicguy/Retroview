//
//  AddToCollectionMenu.swift
//  Retroview
//
//  Created by Adam Schuster on 11/27/24.
//

import SwiftData
import SwiftUI

struct AddToCollectionMenu: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CollectionSchemaV1.Collection.name) private var collections:
        [CollectionSchemaV1.Collection]
    @State private var showingNewCollectionSheet = false

    let card: CardSchemaV1.StereoCard

    var body: some View {
        Menu {
            if collections.isEmpty {
                Text("No Collections")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(collections) { collection in
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

                Divider()
            }

            Button {
                showingNewCollectionSheet = true
            } label: {
                Label("New Collection...", systemImage: "folder.badge.plus")
            }
        } label: {
            Label("Add to Collection", systemImage: "folder")
        }
        .sheet(isPresented: $showingNewCollectionSheet) {
            NewCollectionSheet(card: card)
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

struct NewCollectionSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var collectionName = ""
    let card: CardSchemaV1.StereoCard

    var body: some View {
        NavigationStack {
            Form {
                TextField("Collection Name", text: $collectionName)
            }
            .platformNavigationTitle("New Collection")
            .platformToolbar {
                platformDismissButton {
                    dismiss()
                }
            } trailing: {
                toolbarButton(title: "Create", systemImage: "folder.badge.plus") {
                    createCollection()
                }
                .disabled(collectionName.isEmpty)
            }
        }
        .frame(minWidth: 300, minHeight: 150)
    }

    private func createCollection() {
        let collection = CollectionSchemaV1.Collection(name: collectionName)
        collection.addCard(card)
        modelContext.insert(collection)
        try? modelContext.save()
        dismiss()
    }
}

#Preview("New Collection Sheet") {
    let descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
    let container = try! PreviewDataManager.shared.container()
    let card = try! container.mainContext.fetch(descriptor).first!
    
    return NewCollectionSheet(card: card)
        .withPreviewData()
}
