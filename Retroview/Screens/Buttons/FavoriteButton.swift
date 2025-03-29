//
//  FavoriteButton.swift
//  Retroview
//
//  Created by Adam Schuster on 11/28/24.
//

import OSLog
import SwiftData
import SwiftUI

private let logger = Logger(
    subsystem: "com.example.retroview", category: "FavoritesUI")

struct FavoriteButton: View {
    @Environment(\.modelContext) private var modelContext
    @Query(filter: ModelPredicates.Collection.favorites)
    private var favoritesCollection: [CollectionSchemaV1.Collection]

    let card: CardSchemaV1.StereoCard
    @State private var isProcessing = false

    var body: some View {
        Button {
            guard !isProcessing, let favorites = favoritesCollection.first
            else { return }

            Task {
                isProcessing = true
                try? await Task.sleep(for: .milliseconds(50))

                if favorites.hasCard(card) {
                    favorites.removeCard(card, context: modelContext)
                } else {
                    favorites.addCard(card, context: modelContext)
                }

                isProcessing = false
            }
        } label: {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .overlayButtonStyle(opacity: isProcessing ? 0.5 : 1.0)
        }
        .buttonStyle(.plain)
        .platformInteraction(
            InteractionConfig(
                showHoverEffects: true
            )
        )
        .disabled(isProcessing)
        .help(isFavorite ? "Favorite" : "Not Favorite")
    }

    private var isFavorite: Bool {
        favoritesCollection.first?.hasCard(card) ?? false
    }
}

#Preview("Favorite Button States") {
    let previewContainer = try! PreviewDataManager.shared.container()
    let context = previewContainer.mainContext
    
    // Ensure we have a card
    let card = try! context.fetch(FetchDescriptor<CardSchemaV1.StereoCard>()).first!
    let card2 = try! context.fetch(FetchDescriptor<CardSchemaV1.StereoCard>()).last!
    
    // Create favorites collection if needed
    let favorites = CollectionSchemaV1.Collection(name: CollectionDefaults.favoritesName)
    context.insert(favorites)
    favorites.addCard(card, context: context)
    try! context.save()
    
    return HStack(spacing: 20) {
        // Not favorited
        VStack {
            Text("Not Favorited")
                .font(.caption)
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 100, height: 100)
                .overlay {
                    FavoriteButton(card: card2)
                }
        }
        
        // Favorited
        VStack {
            Text("Favorited")
                .font(.caption)
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.2))
                .frame(width: 100, height: 100)
                .overlay {
                    FavoriteButton(card: card)
                }
        }
    }
    .withPreviewStore()
    .padding()
}

#Preview("Favorite Button Processing") {
    let previewContainer = try! PreviewDataManager.shared.container()
    let context = previewContainer.mainContext
    let card = try! context.fetch(FetchDescriptor<CardSchemaV1.StereoCard>()).first!
    
    return VStack {
        Text("Click to see processing animation")
            .font(.caption)
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.gray.opacity(0.2))
            .frame(width: 100, height: 100)
            .overlay {
                FavoriteButton(card: card)
            }
    }
    .withPreviewStore()
    .padding()
}
