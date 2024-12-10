//
//  AddToCollectionSheet.swift
//  Retroview
//
//  Created by Adam Schuster on 12/9/24.
//

import SwiftUI
import SwiftData

struct AddToCollectionSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var collectionName = ""
    let card: CardSchemaV1.StereoCard
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Collection Name", text: $collectionName)
            }
            .navigationTitle("New Collection")
//            .navigationBarTitleDisplayMode(.inline)
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
        let collection = CollectionSchemaV1.Collection(name: collectionName)
        collection.addCard(card)
        modelContext.insert(collection)
        try? modelContext.save()
        dismiss()
    }
}

#Preview("Add to Collection Sheet") {
    let descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
    let container = try! PreviewDataManager.shared.container
    let card = try! container?.mainContext.fetch(descriptor).first!
    
    AddToCollectionSheet(card: card!)
        .withPreviewData()
}
