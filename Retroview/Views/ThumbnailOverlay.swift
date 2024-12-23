//
//  ThumbnailOverlay.swift
//  Retroview
//
//  Created by Adam Schuster on 12/19/24.
//

import SwiftUI

struct ThumbnailOverlay: View {
    let card: CardSchemaV1.StereoCard
    let isHovering: Bool
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Semi-transparent gradient for better button visibility
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
        // Always show filled heart if card is in Favorites
        return card.collections.contains(where: {
            $0.name == CollectionDefaults.favoritesName
        })
    }
}
