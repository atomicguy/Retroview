//
//  ThumbnailOverlay.swift
//  Retroview
//
//  Created by Adam Schuster on 12/19/24.
//

import SwiftUI

struct ThumbnailOverlay: View {
    let card: CardSchemaV1.StereoCard
    @State private var showingNewCollectionSheet = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Semi-transparent gradient for better button visibility
            LinearGradient(
                colors: [.black.opacity(0.3), .clear],
                startPoint: .top,
                endPoint: .center
            )
            
            // Button Layout
            VStack {
                HStack {
                    Spacer()
                    FavoriteButton(card: card)
                        .padding(8)
                }
                
                Spacer()
                
                HStack {
                    CollectionMenuButton(
                        card: card,
                        showingNewCollectionSheet: $showingNewCollectionSheet
                    )
                    .padding(8)
                    Spacer()
                }
            }
        }
        .sheet(isPresented: $showingNewCollectionSheet) {
            NewCollectionSheet(
                card: card,
                isPresented: $showingNewCollectionSheet
            )
        }
    }
}
