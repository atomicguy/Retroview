//
//  MainView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/20/24.
//

import SwiftData
import SwiftUI

struct MainView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CollectionSchemaV1.Collection.name) private var collections:
        [CollectionSchemaV1.Collection]
    @State private var selectedDestination: AppDestination?
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationSplitView {
            Sidebar(selectedDestination: $selectedDestination)
        } detail: {
            NavigationStack(path: $navigationPath) {
                contentView
                    .navigationDestination(for: CardStackDestination.self) {
                        destination in
                        switch destination {
                        case .stack(let cards, let initialCard):
                            CardDetailStackView(
                                cards: cards, initialCard: initialCard)
                        }
                    }
                    .navigationDestination(for: SubjectSchemaV1.Subject.self) {
                        subject in
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
                    .navigationDestination(for: AuthorSchemaV1.Author.self) {
                        author in
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
                    .navigationDestination(
                        for: CollectionSchemaV1.Collection.self
                    ) { collection in
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
                        .platformNavigationTitle(
                            "\(collection.name) (\(collection.orderedCards.count) cards)"
                        )
                    }
            }
            .modifier(SerifFontModifier())
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch selectedDestination {
        case .none, .library:
            LibraryGridView(
                modelContext: modelContext, navigationPath: $navigationPath)

        case .subjects:
            CatalogListView<SubjectSchemaV1.Subject>(
                title: "Subjects",
                navigationPath: $navigationPath,
                sortDescriptor: SortDescriptor(\SubjectSchemaV1.Subject.name)
            )

        case .authors:
            CatalogListView<AuthorSchemaV1.Author>(
                title: "Authors",
                navigationPath: $navigationPath,
                sortDescriptor: SortDescriptor(\AuthorSchemaV1.Author.name)
            )

        case let .collection(id, _):
            if let collection = collections.first(where: { $0.id == id }) {
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
                .platformNavigationTitle(collection.name)
            } else {
                ContentUnavailableView(
                    "Collection Not Found",
                    systemImage: "exclamationmark.triangle")
            }
        }
    }
}

#Preview("Main View") {
    MainView()
        .withPreviewStore()
}
