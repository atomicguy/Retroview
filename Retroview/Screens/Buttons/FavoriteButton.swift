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
    @Query(
        filter: ModelPredicates.Collection.favorites,
        sort: \.name
    ) private var favoritesCollection: [CollectionSchemaV1.Collection]

    let card: CardSchemaV1.StereoCard
    @State private var isProcessing = false

    var body: some View {
        Button {
            guard !isProcessing, let favorites = favoritesCollection.first
            else { return }

            Task {
                isProcessing = true

                // Add artificial delay to prevent rapid tapping
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
                .font(.title2)
                .foregroundStyle(.white)
                .shadow(radius: 2)
                .opacity(isProcessing ? 0.5 : 1.0)
        }
        .buttonStyle(.plain)
        .platformInteraction()
        .disabled(isProcessing)
    }

    private var isFavorite: Bool {
        favoritesCollection.first?.hasCard(card) ?? false
    }
}
