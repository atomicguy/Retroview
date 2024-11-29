//
//  ReorderableGridView.swift
//  Retroview
//
//  Created by Adam Schuster on 11/27/24.
//

import SwiftData
import SwiftUI

// MARK: - Grid Item View

private struct ReorderableGridItem: View {
    let card: CardSchemaV1.StereoCard
    let selectedCard: CardSchemaV1.StereoCard?
    let currentCollection: CollectionSchemaV1.Collection
    let onSelect: (CardSchemaV1.StereoCard) -> Void
    @State private var isDragging = false

    var body: some View {
        SquareCropView(card: card, currentCollection: currentCollection)
            .contentShape(Rectangle())
            .onTapGesture {
                onSelect(card)
            }
            .overlay {
                if selectedCard?.uuid == card.uuid {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.accentColor, lineWidth: 3)
                }
            }
            .draggable(card) {
                SquareCropView(card: card)
                    .frame(width: 200, height: 200)
                    .opacity(0.8)
            }
            .opacity(isDragging ? 0.5 : 1.0)
            .scaleEffect(isDragging ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isDragging)
    }
}

// MARK: - Grid Content View

private struct ReorderableGridContent: View {
    let cards: [CardSchemaV1.StereoCard]
    let selectedCard: CardSchemaV1.StereoCard?
    let collection: CollectionSchemaV1.Collection
    let onSelect: (CardSchemaV1.StereoCard) -> Void
    let onReorder: ([CardSchemaV1.StereoCard]) -> Void

    private let columns = [
        GridItem(.adaptive(minimum: 250, maximum: 300), spacing: 10),
    ]
    private let spacing: CGFloat = 10
    private let minItemWidth: CGFloat = 250

    var body: some View {
        LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(cards) { card in
                ReorderableGridItem(
                    card: card,
                    selectedCard: selectedCard,
                    currentCollection: collection,
                    onSelect: onSelect
                )
            }
        }
        .padding()
    }

    func calculateDropIndex(at location: CGPoint, containerWidth: CGFloat)
        -> Int
    {
        let itemsPerRow = max(1, Int(containerWidth / (minItemWidth + spacing)))
        let row = Int(location.y / (minItemWidth + spacing))
        let column = Int(location.x / (minItemWidth + spacing))
        let index = (row * itemsPerRow) + column
        return min(max(0, index), cards.count)
    }
}

// MARK: - Main View

struct ReorderableCardGridView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var cards: [CardSchemaV1.StereoCard]
    @Binding var selectedCard: CardSchemaV1.StereoCard?
    let collection: CollectionSchemaV1.Collection
    let onReorder: ([CardSchemaV1.StereoCard]) -> Void

    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                ReorderableGridContent(
                    cards: cards,
                    selectedCard: selectedCard,
                    collection: collection,
                    onSelect: { selectedCard = $0 },
                    onReorder: onReorder
                )
                .dropDestination(for: String.self) { droppedIds, location in
                    handleDrop(
                        droppedIds: droppedIds, location: location,
                        geometry: geometry
                    )
                }
            }
        }
    }

    private func handleDrop(
        droppedIds: [String], location: CGPoint, geometry: GeometryProxy
    ) -> Bool {
        guard let droppedId = droppedIds.first,
              let droppedUUID = UUID(uuidString: droppedId),
              let sourceIndex = cards.firstIndex(where: { $0.uuid == droppedUUID }
              )
        else { return false }

        let content = ReorderableGridContent(
            cards: cards,
            selectedCard: selectedCard,
            collection: collection,
            onSelect: { selectedCard = $0 },
            onReorder: onReorder
        )

        let dropIndex = content.calculateDropIndex(
            at: location, containerWidth: geometry.size.width
        )
        var updatedCards = cards

        let movedCard = updatedCards.remove(at: sourceIndex)
        let actualDropIndex =
            dropIndex >= sourceIndex ? dropIndex - 1 : dropIndex
        updatedCards.insert(
            movedCard, at: min(actualDropIndex, updatedCards.count)
        )

        cards = updatedCards
        onReorder(updatedCards)

        return true
    }
}

#Preview("Reorderable Grid") {
    CardsPreviewContainer { cards in
        ReorderableCardGridView(
            cards: .constant(cards),
            selectedCard: .constant(nil),
            collection: CollectionSchemaV1.Collection.preview,
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
            collection: CollectionSchemaV1.Collection.preview,
            onReorder: { _ in }
        )
        .frame(width: 1200, height: 800)
    }
}
