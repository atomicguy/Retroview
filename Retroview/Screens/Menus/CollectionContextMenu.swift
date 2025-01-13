//
//  CollectionContextMenu.swift
//  Retroview
//
//  Created by Adam Schuster on 1/12/25.
//

import SwiftData
import SwiftUI

struct CollectionContextMenu: View {
    @Environment(\.modelContext) private var modelContext
    let collection: CollectionSchemaV1.Collection

    var body: some View {
        Group {
            // Don't allow deletion of Favorites collection
            if !CollectionDefaults.isFavorites(collection) {
                Button(role: .destructive) {
                    deleteCollection()
                } label: {
                    Label("Delete Collection", systemImage: "trash")
                }
            }
            if !CollectionDefaults.isFavorites(collection) {
                Button {
                    regenerateThumbnail()
                } label: {
                    Label(
                        "Regenerate Thumbnail",
                        systemImage: "arrow.triangle.2.circlepath")
                }
            }
        }
    }

    private func deleteCollection() {
        // Remove the collection from the model context
        modelContext.delete(collection)

        // Save changes in a background task
        Task {
            try? await Task.sleep(for: .milliseconds(100))
            try? modelContext.save()
        }
    }

    private func regenerateThumbnail() {
        Task { @MainActor in
            do {
                try await collection.updateThumbnail(context: modelContext)
            } catch {
                print("Failed to generate thumbnail: \(error)")
            }
        }
    }
}

// Helper view modifier to add collection context menu
struct CollectionContextMenuModifier: ViewModifier {
    let collection: CollectionSchemaV1.Collection
    @State private var showDeleteAlert = false

    func body(content: Content) -> some View {
        content
            .contextMenu {
                CollectionContextMenu(collection: collection)
            }
            .alert("Delete Collection", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    deleteCollection()
                }
            } message: {
                Text(
                    "Are you sure you want to delete '\(collection.name)'? This cannot be undone."
                )
            }
    }

    private func deleteCollection() {
        // Implementation remains in the CollectionContextMenu
    }
}

// View extension for easier usage
extension View {
    func withCollectionContextMenu(_ collection: CollectionSchemaV1.Collection)
        -> some View
    {
        modifier(CollectionContextMenuModifier(collection: collection))
    }
}
