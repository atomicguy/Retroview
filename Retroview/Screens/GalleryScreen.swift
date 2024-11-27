//
//  GalleryScreen.swift
//  Retroview
//
//  Created by Adam Schuster on 11/26/24.
//

import SwiftUI
import SwiftData

struct GalleryScreen: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \CardSchemaV1.StereoCard.uuid) private var cards: [CardSchemaV1.StereoCard]
    @State private var selectedCard: CardSchemaV1.StereoCard?
    
    var body: some View {
        NavigationSplitView {
            // Primary column with grid (roughly 70% of the width)
            SquareCropGridView(
                cards: cards,
                selectedCard: $selectedCard
            )
            .navigationTitle("Gallery")
            .frame(minWidth: 700, idealWidth: 800)
        } detail: {
            // Detail column with card content (roughly 30% of the width)
            if let card = selectedCard {
                ScrollView {
                    CardContentView(card: card)
                        .padding()
                }
                .frame(minWidth: 300, idealWidth: 350, maxWidth: 400)
                .id(card.uuid)
            } else {
                ContentUnavailableView(
                    "No Card Selected",
                    systemImage: "photo.on.rectangle",
                    description: Text("Select a card from the gallery to view its details")
                )
            }
        }
        .navigationSplitViewStyle(.prominentDetail)
    }
}

// MARK: - Preview Provider

#Preview {
    GalleryScreen()
        .modelContainer(PreviewHelper.shared.modelContainer)
        .frame(width: 1200, height: 800)
}
