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
    subsystem: "com.example.retroview", category: "CollectionView")

struct CollectionView: View {
    @Bindable var collection: CollectionSchemaV1.Collection
    @State private var selectedCard: CardSchemaV1.StereoCard?
    @State private var navigationPath = NavigationPath()
    @State private var isProcessing = false

    var body: some View {
        NavigationStack(path: $navigationPath) {
            SharedCardGridView(
                cards: collection.orderedCards,
                selectedCard: $selectedCard,
                onCardSelected: { card in navigationPath.append(card) },
                emptyContentTitle: "No Cards",
                emptyContentDescription: "This collection is empty"
            )
            .navigationTitle(collection.name)
            .navigationDestination(for: CardSchemaV1.StereoCard.self) { card in
                CardDetailView(card: card)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(role: .destructive) {
                            Task { @MainActor in
                                guard !isProcessing else { return }
                                isProcessing = true
                                defer { isProcessing = false }

                                logger.debug(
                                    "Clearing collection \(collection.name)")
//                                let cardsToRemove = collection.cards
//                                for card in cardsToRemove {
//                                    collection.removeCard(
//                                        card, context: modelContext)
//                                }
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
        }
    }
}
