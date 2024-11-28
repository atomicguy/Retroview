//
//  ReorderableCardGridView.swift
//  Retroview
//
//  Created by Adam Schuster on 11/27/24.
//

import SwiftData
import SwiftUI

struct ReorderableCardGridView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var cards: [CardSchemaV1.StereoCard]
    @Binding var selectedCard: CardSchemaV1.StereoCard?
    let onReorder: ([CardSchemaV1.StereoCard]) -> Void

    private let columns = [
        GridItem(.adaptive(minimum: 250, maximum: 300), spacing: 10)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
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
                        .draggable(card) {
                            // Preview while dragging
                            SquareCropView(card: card)
                                .frame(width: 200, height: 200)
                                .opacity(0.8)
                        }
                }
            }
            .padding()
            .dropDestination(for: CardSchemaV1.StereoCard.self) {
                droppedItems, location in
                handleDrop(of: droppedItems, at: location)
            } isTargeted: { isTargeted in
                // Add visual feedback when dragging over
                if isTargeted {
                    print("Drop target active")
                }
            }
        }
    }

    private func handleDrop(
        of droppedItems: [CardSchemaV1.StereoCard], at location: CGPoint
    ) -> Bool {
        guard let droppedCard = droppedItems.first else { return false }

        // If card doesn't exist in collection, add it
        if !cards.contains(where: { $0.uuid == droppedCard.uuid }) {
            cards.append(droppedCard)
            onReorder(cards)
            return true
        }

        // Otherwise, handle reordering
        guard
            let sourceIndex = cards.firstIndex(where: {
                $0.uuid == droppedCard.uuid
            }),
            let dropIndex = getDropIndex(location: location)
        else { return false }

        var updatedCards = cards
        let movedCard = updatedCards.remove(at: sourceIndex)
        let actualDropIndex =
            dropIndex >= sourceIndex ? dropIndex - 1 : dropIndex
        updatedCards.insert(movedCard, at: actualDropIndex)

        cards = updatedCards
        onReorder(updatedCards)
        return true
    }

    private func getDropIndex(location: CGPoint) -> Int? {
        let approximateRowHeight: CGFloat = 300
        let row = Int(location.y / approximateRowHeight)
        let approximateItemsPerRow = 4
        return min(row * approximateItemsPerRow, cards.count)
    }
}

#Preview("Reorderable Grid") {
    CardsPreviewContainer { cards in
        ReorderableCardGridView(
            cards: .constant(cards),
            selectedCard: .constant(nil),
            onReorder: { _ in }
        )
        .frame(width: 1200, height: 800)
    }
}

#Preview("Reorderable Grid - With Selection") {
    CardsPreviewContainer { cards in
        ReorderableCardGridView(
            cards: .constant(cards),
            selectedCard: .constant(cards.first),
            onReorder: { _ in }
        )
        .frame(width: 1200, height: 800)
    }
}
