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
    let isHovering: Bool

    var body: some View {
        ZStack(alignment: .bottom) {
            // Gradient overlay for better button visibility
            LinearGradient(
                colors: [.clear, .black.opacity(0.4)],
                startPoint: .center,
                endPoint: .bottom
            )

            // Button Layout
            HStack {
                FavoriteButton(card: card)
                    .opacity(isFavoriteVisible ? 1 : (isHovering ? 1 : 0))
                    .padding(8)

                Spacer()

                CollectionMenuButton(card: card)
                    .opacity(isHovering ? 1 : 0)
                    .padding(8)
            }
            .padding(.bottom, 4)
        }
    }

    private var isFavoriteVisible: Bool {
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

    return ThumbnailOverlay(card: card, isHovering: true)
        .withPreviewStore()
        .frame(width: 300, height: 200)
}
