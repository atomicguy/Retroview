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
        case .favorites:
            FavoritesView(navigationPath: $navigationPath)
        case .collections:
            CollectionsGridView(navigationPath: $navigationPath)
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
