//
//  ThumbnailOverlay.swift
//  Retroview
//
//  Created by Adam Schuster on 12/19/24.
//

import SwiftUI

struct ThumbnailOverlay: View {
    let card: CardSchemaV1.StereoCard
    
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
                    .padding(8)
                
                Spacer()
                
                CollectionMenuButton(card: card)
                    .padding(8)
            }
            .padding(.bottom, 4)
        }
    }
}
