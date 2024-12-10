//
//  CollectionMenu.swift
//  Retroview
//
//  Created by Adam Schuster on 12/9/24.
//

import SwiftData
import SwiftUI

struct CollectionMenu: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CollectionSchemaV1.Collection.name) private var collections: [CollectionSchemaV1.Collection]
    @State private var showingNewCollectionSheet = false
    let card: CardSchemaV1.StereoCard
    
    var body: some View {
        Group {
            ForEach(collections) { collection in
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
            
            if !collections.isEmpty {
                Divider()
            }
            
            Button {
                showingNewCollectionSheet = true
            } label: {
                Label("New Collection...", systemImage: "folder.badge.plus")
            }
        }
        .sheet(isPresented: $showingNewCollectionSheet) {
            AddToCollectionSheet(card: card)
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
 
#Preview("Collection Menu") {
    let descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
    let container = try! PreviewDataManager.shared.container
    let card = try! container?.mainContext.fetch(descriptor).first!
    
    CollectionMenu(card: card!)
        .withPreviewData()
        .padding()
}
