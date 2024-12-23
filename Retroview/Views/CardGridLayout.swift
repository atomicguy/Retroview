//
//  CardGridGroup.swift
//  Retroview
//
//  Created by Adam Schuster on 12/20/24.
//

import SwiftData
import SwiftUI

struct CardGridLayout: View {
    @Environment(\.modelContext) private var modelContext
    let cards: [CardSchemaV1.StereoCard]
    @Binding var selectedCard: CardSchemaV1.StereoCard?
    let onCardSelected: (CardSchemaV1.StereoCard) -> Void
    
    // Platform-specific grid settings using centralized metrics
    private var columns: [GridItem] {
        [
            GridItem(.adaptive(
                minimum: PlatformEnvironment.Metrics.gridMinWidth,
                maximum: PlatformEnvironment.Metrics.gridMaxWidth
            ), spacing: 20)
        ]
    }
    
    private var gridSpacing: CGFloat {
        PlatformEnvironment.Metrics.gridSpacing
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: gridSpacing) {
                ForEach(cards) { card in
                    SelectableThumbnailView(
                        card: card,
                        isSelected: card.id == selectedCard?.id,
                        onSelect: { selectedCard = card },
                        onDoubleClick: { onCardSelected(card) }
                    )
                    .contextMenu {
                        Button {
                            onCardSelected(card)
                        } label: {
                            Label("Open", systemImage: "arrow.up.right.square")
                        }
                        
                        if let favorites = card.collections.first(where: { CollectionDefaults.isFavorites($0) }) {
                            Button(role: .destructive) {
                                favorites.removeCard(card, context: modelContext)
                            } label: {
                                Label("Remove from Favorites", systemImage: "heart.slash")
                            }
                        } else {
                            Button {
                                Task {
                                    if let favorites = try? modelContext.fetch(FetchDescriptor(
                                        predicate: ModelPredicates.Collection.favorites
                                    )).first {
                                        favorites.addCard(card, context: modelContext)
                                    }
                                }
                            } label: {
                                Label("Add to Favorites", systemImage: "heart")
                            }
                        }
                    }
                }
            }
            .padding(PlatformEnvironment.Metrics.defaultPadding)
        }
    }
}
