//
//  LibraryView.swift
//  Retroview
//
//  Created by Adam Schuster on 11/26/24.
//

import SwiftData
import SwiftUI

struct LibraryView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \CardSchemaV1.StereoCard.uuid) private var cards: [CardSchemaV1.StereoCard]
    @State private var selectedCard: CardSchemaV1.StereoCard?

    var body: some View {
        HStack(spacing: 0) {
            // For library view we don't need the list content
            CardGroupingGrid(
                cards: cards,
                selectedCard: $selectedCard,
                currentCollection: nil
            )
            .frame(maxWidth: .infinity)

            Divider()

            Group {
                if let card = selectedCard {
                    CardContentView(card: card)
                        .id(card.uuid)
                        .transition(.move(edge: .trailing))
                } else {
                    ContentUnavailableView(
                        "No Card Selected",
                        systemImage: "photo.on.rectangle",
                        description: Text("Select a card to view its details")
                    )
                    .transition(.opacity)
                }
            }
            .animation(.smooth, value: selectedCard)
            .frame(width: 300)
        }
    }
}

// MARK: - Preview Provider

#Preview("Library View") {
    LibraryView()
        .withPreviewData()
        .frame(width: 1200, height: 800)
}
