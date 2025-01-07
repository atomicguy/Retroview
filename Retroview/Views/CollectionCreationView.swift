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
            .formStyle(.grouped) // Add this for better macOS presentation
            .platformNavigationTitle("New Collection", displayMode: .inline)
            .platformToolbar {
                Button("Cancel") {
                    dismiss()
                }
                .disabled(isProcessing)
            } trailing: {
                Button("Create") {
                    Task {
                        await createCollection()
                    }
                }
                .disabled(collectionName.isEmpty || isProcessing)
            }
            .onAppear {
                isNameFieldFocused = true
            }
        }
        #if os(macOS)
        .frame(minWidth: 400, minHeight: 200, maxHeight: 300)
        #else
        .frame(minWidth: 300, minHeight: 150)
        #endif
        .interactiveDismissDisabled(isProcessing)
    }

    private func createCollection() async {
        guard !isProcessing else { return }
        isProcessing = true
        defer { isProcessing = false }

        let trimmedName = collectionName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }

        do {
            let descriptor = FetchDescriptor<CollectionSchemaV1.Collection>(
                predicate: #Predicate<CollectionSchemaV1.Collection> {
                    $0.name == trimmedName
                }
            )

            if let existing = try modelContext.fetch(descriptor).first {
                existing.addCard(card, context: modelContext)
            } else {
                let collection = CollectionSchemaV1.Collection(
                    name: trimmedName)
                modelContext.insert(collection)
                collection.addCard(card, context: modelContext)
            }

            dismiss()
        } catch {
            self.error = error
        }
    }
}

#Preview("Collection Creation View") {
    // Create a mock card for preview
    let mockCard = CardSchemaV1.StereoCard(
        uuid: UUID(),
        titles: [TitleSchemaV1.Title(text: "Sample Title")],
        authors: [AuthorSchemaV1.Author(name: "John Doe")]
    )
    
    return CollectionCreationView(card: mockCard)
        .frame(minWidth: 300, minHeight: 150)
}
