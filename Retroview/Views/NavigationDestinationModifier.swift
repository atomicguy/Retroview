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
            .navigationDestination(for: CardStackDestination.self) { destination in
                switch destination {
                case .stack(let cards, let initialCard):
                    CardDetailStackView(cards: cards, initialCard: initialCard)
                }
            }
            .navigationDestination(for: SubjectSchemaV1.Subject.self) { subject in
                CardGridLayout(
                    cards: subject.cards,
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
                .platformNavigationTitle(subject.name)
            }
            .navigationDestination(for: AuthorSchemaV1.Author.self) { author in
                CardGridLayout(
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
                .platformNavigationTitle(author.name)
            }
            .navigationDestination(for: CollectionSchemaV1.Collection.self) { collection in
                CardGridLayout(
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
                .platformNavigationTitle("\(collection.name) (\(collection.orderedCards.count) cards)")
            }
    }
}

extension View {
    func withNavigationDestinations(navigationPath: Binding<NavigationPath>) -> some View {
        modifier(NavigationDestinationModifier(navigationPath: navigationPath))
    }
}
