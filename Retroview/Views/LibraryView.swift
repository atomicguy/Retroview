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
    @Query(sort: \CardSchemaV1.StereoCard.uuid) private var cards:
        [CardSchemaV1.StereoCard]
    @State private var selectedCard: CardSchemaV1.StereoCard?

    // Fixed width for details panel
    private let detailWidth: CGFloat = 300

    var body: some View {
        HStack(spacing: 0) {
            // Main grid area (expanding/contracting)
            AdaptiveGridView(cards: cards, selectedCard: $selectedCard)
                .frame(maxWidth: .infinity)

            // Divider for visual separation
            Divider()

            // Details area (fixed width)
            Group {
                if let card = selectedCard {
                    CardContentView(card: card)
                        .id(card.uuid) // Force full refresh when card changes
                } else {
                    ContentUnavailableView(
                        "No Card Selected",
                        systemImage: "photo.on.rectangle",
                        description: Text("Select a card to view its details")
                    )
                }
            }
            .frame(width: detailWidth)
        }
    }
}

// MARK: - Adaptive Grid View

private struct AdaptiveGridView: View {
    let cards: [CardSchemaV1.StereoCard]
    @Binding var selectedCard: CardSchemaV1.StereoCard?

    // Minimum space between items
    private let spacing: CGFloat = 10
    // Minimum width for each item
    private let minItemWidth: CGFloat = 250

    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: [
                    GridItem(.adaptive(minimum: minItemWidth), spacing: spacing),
                ],
                spacing: spacing
            ) {
                ForEach(cards) { card in
                    SquareCropView(card: card)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedCard = card
                        }
                        .overlay {
                            if selectedCard?.uuid == card.uuid {
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.accentColor, lineWidth: 3)
                            }
                        }
                }
            }
            .padding()
        }
    }
}

// MARK: - Preview Provider

#Preview("Library") {
    LibraryView()
        .withPreviewContainer()
        .frame(width: 1200, height: 800)
}
