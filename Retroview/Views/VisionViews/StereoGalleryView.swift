//
//  StereoGalleryView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/27/24.
//

import QuickLook
import RealityKit
import SwiftUI

struct StereoGalleryView: View {
    let cards: [CardSchemaV1.StereoCard]
    let initialCard: CardSchemaV1.StereoCard?

    @Environment(\.dismiss) private var dismiss
    @State private var selectedIndex: Int
    @State private var previewSession: PreviewSession?

    init(
        cards: [CardSchemaV1.StereoCard],
        initialCard: CardSchemaV1.StereoCard? = nil
    ) {
        self.cards = cards
        self.initialCard = initialCard
        self._selectedIndex = State(
            initialValue: initialCard.flatMap { cards.firstIndex(of: $0) } ?? 0)
    }

    var body: some View {
        VStack {
            Spacer()

            // Thumbnail strip at bottom
            StereoGalleryStrip(cards: cards, selectedIndex: $selectedIndex)
                .padding(.bottom)
        }
        .onChange(of: selectedIndex) { _, newIndex in
            if let card = cards[safe: newIndex] {
                previewSession = PreviewApplication.openCard(card)
            }
        }
        .onAppear {
            // Open initial set of photos
            previewSession = PreviewApplication.openCards(
                cards, selectedCard: initialCard)
        }
    }
}

// Helper extension for safe array access
extension Collection {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

#Preview("Stereo Gallery - Multiple Cards") {
    CardsPreviewContainer(count: 5) { cards in
        StereoGalleryView(cards: cards, initialCard: cards.first)
            .frame(width: 800, height: 600)
    }
}

#Preview("Stereo Gallery - Single Card") {
    CardPreviewContainer { card in
        StereoGalleryView(cards: [card], initialCard: card)
            .frame(width: 800, height: 600)
    }
}

#Preview("Stereo Gallery - Empty State") {
    StereoGalleryView(cards: [], initialCard: nil)
        .frame(width: 800, height: 600)
}
