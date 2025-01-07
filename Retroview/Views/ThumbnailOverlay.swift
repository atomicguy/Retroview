//
//  ThumbnailOverlay.swift
//  Retroview
//
//  Created by Adam Schuster on 12/19/24.
//

import SwiftUI

#if DEBUG
    import SwiftData
#endif

struct ThumbnailOverlay: View {
    let card: CardSchemaV1.StereoCard
    let isVisible: Bool

    var body: some View {
        ZStack(alignment: .bottom) {
            // Background gradient
            LinearGradient(
                colors: [.clear, .black.opacity(0.4)],
                startPoint: .center,
                endPoint: .bottom
            )
            .opacity(shouldShowGradient ? 1 : 0)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            // Controls
            HStack {
                // Favorite button
                FavoriteButton(card: card)
                    .opacity(shouldShowFavoriteButton ? 1 : 0)
                    .padding(8)

                Spacer()

                // Menu button
                if shouldShowMenu {
                    CardActionMenu(card: card, showDirectMenu: .constant(false))
                        .padding(8)
                        .contentShape(Rectangle())
                        .allowsHitTesting(true)
                }
            }
            .padding(.bottom, 4)
        }
    }

    private var shouldShowGradient: Bool {
        #if os(visionOS) || os(macOS)
            return isVisible
        #else
            return false
        #endif
    }

    private var shouldShowFavoriteButton: Bool {
        // Always show if card is favorited
        if isFavorite {
            return true
        }

        // Otherwise, show based on hover/visibility state
        #if os(macOS) || os(visionOS)
            return isVisible
        #else
            return true  // Always visible on iOS/iPadOS
        #endif
    }

    private var shouldShowMenu: Bool {
        #if os(macOS)
            return isVisible
        #else
            return false
        #endif
    }

    private var isFavorite: Bool {
        card.collections.contains {
            $0.name == CollectionDefaults.favoritesName
        }
    }
}

#Preview("Thumbnail Overlay States") {
    let previewContainer = try! PreviewDataManager.shared.container()
    let context = previewContainer.mainContext

    // Ensure we have a card
    let card = try! context.fetch(FetchDescriptor<CardSchemaV1.StereoCard>())
        .first!
    let card2 = try! context.fetch(FetchDescriptor<CardSchemaV1.StereoCard>())
        .last!

    // Create a non-favorited view
    let normalCard = HStack(spacing: 20) {
        // Not hovered
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.gray.opacity(0.2))
            .frame(width: 400, height: 200)
            .overlay(
                ThumbnailOverlay(card: card2, isVisible: false)
                    .withPreviewStore()
            )

        // Hovered
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.gray.opacity(0.2))
            .frame(width: 400, height: 200)
            .overlay(
                ThumbnailOverlay(card: card2, isVisible: true)
                    .withPreviewStore()
            )
    }
    .padding()
    .withPreviewStore()

    // Create favorites collection if needed
    let favorites = CollectionSchemaV1.Collection(
        name: CollectionDefaults.favoritesName)
    context.insert(favorites)
    favorites.addCard(card, context: context)
    try! context.save()

    // Create a favorited view
    let favoritedCard = HStack(spacing: 20) {
        // Not hovered
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.gray.opacity(0.2))
            .frame(width: 400, height: 200)
            .overlay(
                ThumbnailOverlay(card: card, isVisible: false)
                    .withPreviewStore()
            )

        // Hovered
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.gray.opacity(0.2))
            .frame(width: 400, height: 200)
            .overlay(
                ThumbnailOverlay(card: card, isVisible: true)
                    .withPreviewStore()
            )
    }
    .padding()
    .withPreviewStore()

    return VStack(spacing: 32) {
        VStack(alignment: .leading) {
            Text("Regular Card").font(.headline)
            normalCard
        }
        VStack(alignment: .leading) {
            Text("Favorited Card").font(.headline)
            favoritedCard
        }
    }
}
