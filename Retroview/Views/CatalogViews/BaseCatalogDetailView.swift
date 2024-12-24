//
//  CatalogDetailView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/22/24.
//

import SwiftData
import SwiftUI

struct BaseCatalogDetailView<Item: CatalogItem>: View {
    let item: Item
    @State private var selectedCard: CardSchemaV1.StereoCard?
    
    var body: some View {
        CardGridLayout(
            cards: item.cards,
            selectedCard: $selectedCard,
            onCardSelected: { card in
                selectedCard = card
            }
        )
        .navigationTitle(item.name)
        .navigationDestination(for: CardSchemaV1.StereoCard.self) { card in
            CardDetailView(card: card)
                .platformNavigationTitle(
                    card.titlePick?.text ?? "Card Details",
                    displayMode: .inline
                )
        }
        .navigationDestination(for: SubjectSchemaV1.Subject.self) { subject in
            BaseCatalogDetailView<SubjectSchemaV1.Subject>(item: subject)
        }
        .navigationDestination(for: AuthorSchemaV1.Author.self) { author in
            BaseCatalogDetailView<AuthorSchemaV1.Author>(item: author)
        }
        .navigationDestination(for: CollectionSchemaV1.Collection.self) { collection in
            CollectionView(collection: collection)
        }
    }
}
