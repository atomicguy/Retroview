//
//  CollectionCreationView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/21/24.
//

import OSLog
import SwiftData
import SwiftUI

private let logger = Logger(
    subsystem: "com.example.retroview", category: "CollectionCreation")

struct CollectionCreationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let card: CardSchemaV1.StereoCard
    @State private var collectionName = ""
    @State private var isProcessing = false
    @State private var error: Error?
    @FocusState private var isNameFieldFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Collection Name", text: $collectionName)
                        .focused($isNameFieldFocused)
                        .textFieldStyle(.roundedBorder)
                        .disabled(isProcessing)
                }

                if let error {
                    Section {
                        Text(error.localizedDescription)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("New Collection")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .disabled(isProcessing)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        Task {
                            await createCollection()
                        }
                    }
                    .disabled(collectionName.isEmpty || isProcessing)
                }
            }
            .onAppear {
                isNameFieldFocused = true
            }
        }
        .frame(minWidth: 300, minHeight: 150)
    }

    private func createCollection() async {
        guard !isProcessing else { return }
        isProcessing = true
        defer { isProcessing = false }
        
        let trimmedName = collectionName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        
        logger.debug("Creating new collection: \(trimmedName)")
        
        do {
            let descriptor = FetchDescriptor<CollectionSchemaV1.Collection>(
                predicate: #Predicate<CollectionSchemaV1.Collection> {
                    $0.name == trimmedName
                }
            )
            
            if let existing = try modelContext.fetch(descriptor).first {
                logger.debug("Collection with name already exists, adding card to existing collection")
                existing.addCard(card, context: modelContext)
            } else {
                logger.debug("Creating new collection and adding card")
                let collection = CollectionSchemaV1.Collection(name: trimmedName)
                modelContext.insert(collection)
                collection.addCard(card, context: modelContext)
            }
            
            dismiss()
        } catch {
            logger.error("Failed to create collection: \(error.localizedDescription)")
            self.error = error
        }
    }
}

//#Preview {
//    CardPreviewContainer { card in
//        CollectionCreationView(card: card)
//    }
//}
