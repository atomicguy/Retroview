//
//  NewCollectionSheet.swift
//  Retroview
//
//  Created by Adam Schuster on 12/19/24.
//

import SwiftUI
import SwiftData

struct NewCollectionSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let card: CardSchemaV1.StereoCard
    @Binding var isPresented: Bool
    @State private var collectionName = ""
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Collection Name", text: $collectionName)
            }
            .serifNavigationTitle("New Collection")
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
        .frame(minWidth: 300, minHeight: 150)
    }
    
    private func createCollection() {
        let collection = CollectionSchemaV1.Collection(name: collectionName.trimmingCharacters(in: .whitespaces))
        modelContext.insert(collection)
        
        // Add the card to the new collection
        collection.addCard(card, context: modelContext)
        
        dismiss()
    }
}
