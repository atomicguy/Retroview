//
//  VisionBrowserView.swift
//  Retroview
//
//  Created by Adam Schuster on 11/25/24.
//

import SwiftData
import SwiftUI

struct VisionBrowserView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \CardSchemaV1.StereoCard.uuid) private var cards: [CardSchemaV1.StereoCard]
    @State private var selectedCard: CardSchemaV1.StereoCard?
    
    var body: some View {
        NavigationSplitView {
            // First column: Card list
            ScrollView {
                ModernCardListView(cards: cards, selectedCard: $selectedCard)
                    .padding(.horizontal)
                    .scaleEffect(0.85)
            }
            .frame(minWidth: 350, idealWidth: 400, maxWidth: 450)
            .navigationTitle("Cards")
        } content: {
            // Second column: Card content
            if let card = selectedCard {
                ScrollView {
                    CardContentView(card: card)
                        .scaleEffect(0.9)
                        .padding()
                        // Add an ID to force view refresh when card changes
                        .id(card.uuid)
                }
                .frame(minWidth: 400, idealWidth: 500, maxWidth: 600)
                .navigationTitle("Details")
            } else {
                ContentUnavailableView("Select a Card",
                    systemImage: "photo.stack",
                    description: Text("Choose a stereo card from the list to view its details")
                )
            }
        } detail: {
            // Third column: Stereo view
            if let card = selectedCard {
                StereoView(card: card)
                    .navigationTitle("Stereo View")
                    .frame(minWidth: 500, idealWidth: 600, maxWidth: .infinity)
                    // Add an ID to force view refresh when card changes
                    .id(card.uuid)
            } else {
                ContentUnavailableView("No Card Selected",
                    systemImage: "view.3d",
                    description: Text("Select a card to view it in stereo")
                )
            }
        }
        .navigationSplitViewStyle(.prominentDetail)
    }
}

#Preview {
    VisionBrowserView()
        .modelContainer(PreviewHelper.shared.modelContainer)
}
