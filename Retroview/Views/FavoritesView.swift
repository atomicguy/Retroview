//
//  FavoritesView.swift
//  Retroview
//
//  Created by Adam Schuster on 1/6/25.
//

import SwiftUI
import SwiftData

struct FavoritesView: View {
    @Binding var navigationPath: NavigationPath
    @Query(filter: ModelPredicates.Collection.favorites)
    private var favorites: [CollectionSchemaV1.Collection]
    
    var body: some View {
        Group {
            if let favorite = favorites.first {
                CardGridLayout(
                    collection: favorite, cards: favorite.orderedCards,
                    selectedCard: .constant(nil),
                    navigationPath: $navigationPath,
                    onCardSelected: { card in
                        navigationPath.append(
                            CardDetailDestination.stack(
                                cards: favorite.orderedCards,
                                initialCard: card
                            )
                        )
                    }
                )
            } else {
                ContentUnavailableView(
                    "No Favorites",
                    systemImage: "heart.slash",
                    description: Text("Add cards to your favorites to see them here")
                )
            }
        }
    }
}
