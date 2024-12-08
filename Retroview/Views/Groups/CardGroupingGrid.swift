//
//  CardCollectionGrid.swift
//  Retroview
//
//  Created by Adam Schuster on 12/2/24.
//

import SwiftData
import SwiftUI

struct CardGroupingGrid: View {
    let cards: [CardSchemaV1.StereoCard]
    @Binding var selectedCard: CardSchemaV1.StereoCard?
    let currentCollection: CollectionSchemaV1.Collection?
    var onReorder: (([CardSchemaV1.StereoCard]) -> Void)?
    
    private let columns = [
        GridItem(.adaptive(minimum: 250, maximum: 300), spacing: 10)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(cards) { card in
                    CardSquareView(card: card)
                        .withTitle()
                        .cardInteractive(
                            card: card,
                            currentCollection: currentCollection,
                            onSelect: { selectedCard = $0 }
                        )
                        .overlay {
                            if selectedCard?.uuid == card.uuid {
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.accentColor, lineWidth: 3)
                            }
                        }
                        // Add reordering support only when needed
                        .modifier(ReorderingModifier(
                            card: card,
                            cards: cards,
                            onReorder: onReorder
                        ))
                }
            }
            .padding()
        }
//        #if os(visionOS)
//        .ornament(visibility: .hidden) // Hide system ornaments on visionOS
//        #endif
    }
}

// Separate reordering logic into its own modifier
private struct ReorderingModifier: ViewModifier {
    let card: CardSchemaV1.StereoCard
    let cards: [CardSchemaV1.StereoCard]
    let onReorder: (([CardSchemaV1.StereoCard]) -> Void)?
    @State private var isDragging = false
    
    func body(content: Content) -> some View {
        Group {
            if onReorder != nil {
                content
                    .draggable(card) {
                        content
                            .frame(width: 200, height: 200)
                            .opacity(0.8)
                    }
                    .dropDestination(for: CardSchemaV1.StereoCard.self) { items, location in
                        guard let item = items.first,
                              let sourceIndex = cards.firstIndex(of: item),
                              let destinationIndex = calculateDropIndex(at: location)
                        else { return false }
                        
                        var updatedCards = cards
                        let movedItem = updatedCards.remove(at: sourceIndex)
                        let actualIndex = destinationIndex >= sourceIndex ? destinationIndex - 1 : destinationIndex
                        updatedCards.insert(movedItem, at: min(actualIndex, updatedCards.count))
                        
                        onReorder?(updatedCards)
                        return true
                    }
                    .opacity(isDragging ? 0.5 : 1.0)
                    .scaleEffect(isDragging ? 0.95 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: isDragging)
            } else {
                content
            }
        }
    }
    
    private func calculateDropIndex(at location: CGPoint) -> Int? {
        // Basic implementation - could be enhanced based on grid layout
        let index = Int(location.y / 300) * 3 + Int(location.x / 300)
        return index >= 0 && index <= cards.count ? index : nil
    }
}

// MARK: - Preview Provider

#Preview("Card Grid - Basic") {
    let descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
    let container = try! PreviewDataManager.shared.container()
    let cards = try! container.mainContext.fetch(descriptor)
    
    return CardGroupingGrid(
        cards: cards,
        selectedCard: .constant(nil),
        currentCollection: nil
    )
    .frame(width: 1200, height: 800)
    .withPreviewData()
}

//#Preview("Card Grid - With Reordering") {
//    CardsPreviewContainer { cards in
//        CardGroupingGrid(
//            cards: cards,
//            selectedCard: .constant(nil),
//            currentCollection: PreviewContainer.shared.worldsFairCollection,
//            onReorder: { _ in }
//        )
//        .frame(width: 1200, height: 800)
//    }
//}
