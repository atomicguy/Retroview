//
//  NavigationDestinationModifier.swift
//  Retroview
//
//  Created by Adam Schuster on 1/6/25.
//

import SwiftUI

struct NavigationDestinationModifier: ViewModifier {
    @Binding var navigationPath: NavigationPath

    func body(content: Content) -> some View {
        content
            .navigationDestination(for: CardStackDestination.self) {
                destination in
                switch destination {
                case .stack(let cards, let initialCard):
                    CardDetailStackView(cards: cards, initialCard: initialCard)
                }
            }
            .navigationDestination(for: SubjectSchemaV1.Subject.self) {
                subject in
                CardGridLayout(
                    collection:
                        CollectionSchemaV1
                        .Collection(name: subject.name), cards: subject.cards,
                    selectedCard: .constant(nil),
                    navigationPath: $navigationPath,
                    onCardSelected: { card in
                        navigationPath.append(
                            CardStackDestination.stack(
                                cards: subject.cards,
                                initialCard: card
                            ))
                    }
                )
            }
            .navigationDestination(for: AuthorSchemaV1.Author.self) { author in
                CardGridLayout(
                    collection: CollectionSchemaV1.Collection(
                        name: author.name),
                    cards: author.cards,
                    selectedCard: .constant(nil),
                    navigationPath: $navigationPath,
                    onCardSelected: { card in
                        navigationPath.append(
                            CardStackDestination.stack(
                                cards: author.cards,
                                initialCard: card
                            ))
                    }
                )
            }
            .navigationDestination(for: DateSchemaV1.Date.self) { date in
                CardGridLayout(
                    collection: CollectionSchemaV1.Collection(name: date.text),
                    cards: date.cards,
                    selectedCard: .constant(nil),
                    navigationPath: $navigationPath,
                    onCardSelected: { card in
                        navigationPath.append(
                            CardStackDestination.stack(
                                cards: date.cards,
                                initialCard: card
                            ))
                    }
                )
            }
            .navigationDestination(for: CollectionSchemaV1.Collection.self) {
                collection in
                CardGridLayout(
                    collection: collection,
                    cards: collection.orderedCards,
                    selectedCard: .constant(nil),
                    navigationPath: $navigationPath,
                    onCardSelected: { card in
                        navigationPath.append(
                            CardStackDestination.stack(
                                cards: collection.orderedCards,
                                initialCard: card
                            ))
                    }
                )
            }
    }
}

extension View {
    func withNavigationDestinations(navigationPath: Binding<NavigationPath>)
        -> some View
    {
        modifier(NavigationDestinationModifier(navigationPath: navigationPath))
    }
}
