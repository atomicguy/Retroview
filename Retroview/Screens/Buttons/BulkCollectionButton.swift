//
//  BulkCollectionButton.swift
//  Retroview
//
//  Created by Adam Schuster on 12/31/24.
//

import OSLog
import SwiftData
import SwiftUI

private let logger = Logger(
    subsystem: "com.example.retroview", category: "BulkCollectionUI")

struct BulkCollectionButton: View {
    @Environment(\.modelContext) private var modelContext
    @Query(
        filter: #Predicate<CollectionSchemaV1.Collection> { collection in
            collection.name != "Favorites"
        },
        sort: \.name
    ) private var collections: [CollectionSchemaV1.Collection]

    let fetchCards: () -> [CardSchemaV1.StereoCard]
    @State private var isProcessing = false
    @State private var showingCollectionSheet = false

    var body: some View {
        Menu {
            if collections.isEmpty {
                Text("No collections")
            } else {
                ForEach(collections) { collection in
                    Button {
                        Task {
                            guard !isProcessing else { return }
                            isProcessing = true
                            defer { isProcessing = false }

                            let cards = fetchCards()
                            logger.debug(
                                "Bulk adding \(cards.count) cards to collection \(collection.name)"
                            )

                            for card in cards {
                                collection.addCard(card, context: modelContext)
                            }
                            try? modelContext.save()
                        }
                    } label: {
                        Text(collection.name)
                    }
                }
                Divider()
            }

            Button {
                showingCollectionSheet = true
            } label: {
                Label("New Collection...", systemImage: "folder.badge.plus")
            }
        } label: {
            Image(systemName: "rectangle.stack.badge.plus")
                .font(.title2)
        }
        .buttonStyle(.plain)
        .platformInteraction(
            InteractionConfig(
                showHoverEffects: true
            )
        )
        .disabled(isProcessing)
        .sheet(isPresented: $showingCollectionSheet) {
            if let firstCard = fetchCards().first {
                CollectionCreationView(card: firstCard)
            }
        }
    }
}
//#Preview("Bulk Collection Button") {
//    CardsPreviewContainer(count: 5) { cards in
//        BulkCollectionButton(cards: cards)
//            .frame(width: 300, height: 100)
//            .padding()
//    }
//    .withPreviewStore()
//}
