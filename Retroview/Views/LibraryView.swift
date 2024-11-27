//
//  LibraryView.swift
//  Retroview
//
//  Created by Adam Schuster on 11/26/24.
//

import SwiftUI
import SwiftData

struct LibraryView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \CardSchemaV1.StereoCard.uuid) private var cards: [CardSchemaV1.StereoCard]
    @State private var selectedCard: CardSchemaV1.StereoCard?
    
    var body: some View {
        HStack(spacing: 0) {
            // Main grid area (75-80%)
            ScrollView {
                SquareCropGridView(cards: cards, selectedCard: $selectedCard)
            }
            .frame(minWidth: 800, maxHeight: .infinity)
            
            // Divider for visual separation
            Divider()
            
            // Details area (20-25%)
            Group {
                if let card = selectedCard {
                    ScrollView {
                        CardContentView(card: card)
                            .padding()
                    }
                    .id(card.uuid)
                } else {
                    ContentUnavailableView(
                        "No Card Selected",
                        systemImage: "photo.on.rectangle",
                        description: Text("Select a card to view its details")
                    )
                }
            }
            .frame(width: 300)
        }
        .frame(maxHeight: .infinity)
    }
}

// MARK: - Preview Provider

#Preview("Library") {
    LibraryView()
        .modelContainer(PreviewHelper.shared.modelContainer)
        .frame(width: 1200, height: 800)
}
