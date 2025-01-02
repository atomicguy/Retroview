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
                    CardActionMenu(card: card)
                        .padding(8)
                        .contentShape(Rectangle())
                        .allowsHitTesting(true)
                }
            }
            .padding(.bottom, 4)
        }
    }

    private var shouldShowGradient: Bool {
        #if os(visionOS)
            return isVisible
        #elseif os(macOS)
            return isVisible
        #else
            return false
        #endif
    }

    private var shouldShowFavoriteButton: Bool {
        isFavorite || shouldShowOverlayButtons
    }

    private var shouldShowMenu: Bool {
        shouldShowOverlayButtons
    }

    private var shouldShowOverlayButtons: Bool {
        #if os(visionOS)
            return isVisible
        #elseif os(macOS)
            return isVisible
        #else
            return true
        #endif
    }

    private var isFavorite: Bool {
        card.collections.contains {
            $0.name == CollectionDefaults.favoritesName
        }
    }
}

#Preview("Thumbnail Overlay") {
    let previewContainer = try! PreviewDataManager.shared.container()
    let card = try! previewContainer.mainContext.fetch(
        FetchDescriptor<CardSchemaV1.StereoCard>()
    ).first!

    ThumbnailOverlay(card: card, isVisible: true)
        .withPreviewStore()
        .frame(width: 300, height: 200)
}
