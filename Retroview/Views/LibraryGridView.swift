//
//  LibraryGridView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/15/24.
//

import SwiftData
import SwiftUI

struct LibraryGridView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var navigationPath: NavigationPath
    @State private var selectedCard: CardSchemaV1.StereoCard? = nil
    @State private var loadedCards: [CardSchemaV1.StereoCard] = []
    @State private var isLoadingMore = false
    @State private var searchText = ""
    @State private var searchManager: SearchManager? = nil

    init(navigationPath: Binding<NavigationPath>) {
        self._navigationPath = navigationPath
    }

    private let columns = [
        GridItem(
            .adaptive(
                minimum: PlatformEnvironment.Metrics.gridMinWidth,
                maximum: PlatformEnvironment.Metrics.gridMaxWidth
            ), spacing: PlatformEnvironment.Metrics.gridSpacing)
    ]
    
    var searchTextBinding: Binding<String> {
        Binding(
            get: { searchManager?.searchText ?? "" },
            set: { searchManager?.searchText = $0 }
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            SearchBar(text: searchTextBinding)
                .padding(.horizontal)
                .padding(.vertical, 8)

            ScrollView {
                LazyVGrid(
                    columns: columns,
                    spacing: PlatformEnvironment.Metrics.gridSpacing
                ) {
                    ForEach(loadedCards) { card in
                        ThumbnailSelectableView(
                            card: card,
                            isSelected: card.id == selectedCard?.id,
                            onSelect: { selectedCard = card },
                            onDoubleClick: {
                                navigationPath.append(
                                    CardDetailDestination.stack(
                                        cards: loadedCards,
                                        initialCard: card
                                    )
                                )
                            }
                        )
                        .id(card.id)
                    }

                    if !isLoadingMore {
                        Color.clear
                            .onAppear {
                                loadMoreCards()
                            }
                    }
                }
                .padding(PlatformEnvironment.Metrics.defaultPadding)
            }
        }
        .onAppear {
            if searchManager == nil {
                searchManager = SearchManager(modelContext: modelContext)
            }
        }
        .onChange(of: searchManager?.searchText ?? "") {
            Task {
                loadInitialCards()
            }
        }
    }

    @MainActor
    func loadInitialCards() {
        var descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
        descriptor.fetchLimit = 50
        descriptor.relationshipKeyPathsForPrefetching = [
            \CardSchemaV1.StereoCard.titlePick
        ]

        if let searchPredicate = searchManager?.predicate {
            descriptor.predicate = searchPredicate
        }

        do {
            loadedCards = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to load cards: \(error)")
        }
    }

    @MainActor
    func loadMoreCards() {
        guard !isLoadingMore else { return }
        isLoadingMore = true
        defer { isLoadingMore = false }

        var descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
        descriptor.fetchOffset = loadedCards.count
        descriptor.fetchLimit = 50
        descriptor.relationshipKeyPathsForPrefetching = [
            \CardSchemaV1.StereoCard.titlePick
        ]

        if let searchPredicate = searchManager?.predicate {
            descriptor.predicate = searchPredicate
        }

        do {
            let newCards = try modelContext.fetch(descriptor)
            loadedCards.append(contentsOf: newCards)
        } catch {
            print("Failed to load more cards: \(error)")
        }
    }
}

#Preview {
    NavigationStack {
//        let container = try! PreviewDataManager.shared.container()
        LibraryGridView(
            navigationPath: .constant(NavigationPath())
        )
        .withPreviewStore()
        .environment(\.imageLoader, CardImageLoader())
        .frame(width: 1024, height: 400)
    }
}
