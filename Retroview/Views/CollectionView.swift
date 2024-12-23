//
//  CollectionView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/20/24.
//

import OSLog
import SwiftData
import SwiftUI

private let logger = Logger(
    subsystem: "com.example.retroview", category: "CollectionView"
)

struct CollectionView: View {
    @Bindable var collection: CollectionSchemaV1.Collection
    @State private var isProcessing = false

    var body: some View {
        NavigableCardGrid(
            cards: collection.orderedCards,
            emptyTitle: "No Cards",
            emptyDescription: "This collection is empty"
        ) {
            toolbar
        }
    }

    private var toolbar: some View {
        Menu {
            Button(role: .destructive) {
                Task { @MainActor in
                    guard !isProcessing else { return }
                    isProcessing = true
                    defer { isProcessing = false }

                    logger.debug("Clearing collection \(collection.name)")
                    // Uncomment and implement the logic for removing cards if needed
                    // let cardsToRemove = collection.cards
                    // for card in cardsToRemove {
                    // collection.removeCard(card, context: modelContext)
                    // }
                }
            } label: {
                Label("Clear Collection", systemImage: "trash")
            }
            .disabled(isProcessing)
        } label: {
            Label("More", systemImage: "ellipsis.circle")
                .opacity(isProcessing ? 0.5 : 1.0)
        }
    }
}
