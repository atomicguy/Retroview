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
        Group {
                #if os(visionOS)
                    VisionNavigationView(
                        selectedDestination: $selectedDestination,
                        navigationPath: $navigationPath
                    )
                #elseif os(iOS)
                    IPadNavigationView(
                        selectedDestination: $selectedDestination,
                        navigationPath: $navigationPath
                    )
                #else
                    NavigationSplitView {
                        Sidebar(selectedDestination: $selectedDestination)
                    } detail: {
                        NavigationStack(path: $navigationPath) {
                            contentView
                                .withNavigationDestinations(navigationPath: $navigationPath)
                        }
                    }
                #endif
            }
        .modifier(SerifFontModifier())
        .environment(\.createCollection) { card in
            let newCollection = CollectionSchemaV1.Collection(name: "Untitled")
            modelContext.insert(newCollection)
            newCollection.addCard(card, context: modelContext)
            selectedDestination = .collection(
                newCollection.id, newCollection.name)
            navigationPath.append(newCollection)
        }
        .environment(\.createCollectionForMultiple) { cards in
            let newCollection = CollectionSchemaV1.Collection(name: "Untitled")
            modelContext.insert(newCollection)
            for card in cards {
                newCollection.addCard(card, context: modelContext)
            }
            selectedDestination = .collection(
                newCollection.id, newCollection.name)
            navigationPath.append(newCollection)
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch selectedDestination {
        case .none, .library:
            LibraryGridView(
                navigationPath: $navigationPath)
        case .dailyDiscovery:
                DailyDiscoveryView(
                    navigationPath: $navigationPath,
                    modelContext: modelContext
                )
        case .subjects:
            GroupGridView<SubjectSchemaV1.Subject>(
                title: "Subjects",
                navigationPath: $navigationPath,
                sortDescriptor: SortDescriptor(\SubjectSchemaV1.Subject.name)
            )
        case .authors:
            GroupGridView<AuthorSchemaV1.Author>(
                title: "Authors",
                navigationPath: $navigationPath,
                sortDescriptor: SortDescriptor(\AuthorSchemaV1.Author.name)
            )
        case .dates:
            GroupGridView<DateSchemaV1.Date>(
                title: "Dates",
                navigationPath: $navigationPath,
                sortDescriptor: SortDescriptor(\DateSchemaV1.Date.text)
            )
        case .collections:
            GroupGridView<CollectionSchemaV1.Collection>(
                title: "Collections",
                navigationPath: $navigationPath,
                sortDescriptor: SortDescriptor(\.name)
            )
        case .favorites:
            FavoritesView(navigationPath: $navigationPath)
        case let .collection(id, _):
            if let collection = collections.first(where: { $0.id == id }) {
                CardGridLayout(
                    collection: collection,
                    cards: collection.orderedCards,
                    selectedCard: .constant(nil),
                    navigationPath: $navigationPath,
                    onCardSelected: { card in
                        navigationPath.append(
                            CardDetailDestination.stack(
                                cards: collection.orderedCards,
                                initialCard: card
                            ))
                    }
                )
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
