//
//  LibraryGridView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/15/24.
//

import SwiftData
import SwiftUI

struct LibraryGridView: View {
    // MARK: - View State
    private struct ViewState: Codable {
        var searchText = ""
        var currentPage = 0
        var hasMoreContent = true
        var loadedCardIDs: [UUID] = []
    }

    // MARK: - Properties
    @Environment(\.importManager) private var importManager
    @Environment(\.imageDownloadManager) private var imageDownloadManager
    let modelContext: ModelContext
    @Binding var navigationPath: NavigationPath
    @State private var selectedCard: CardSchemaV1.StereoCard?
    @State private var loadedCards: [CardSchemaV1.StereoCard] = []
    @State private var isLoadingMore = false
    @State private var viewState = ViewState()
    @State private var searchText = ""

    private let pageSize = 100

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            SearchBar(text: $searchText)
                .padding(.horizontal)
                .padding(.vertical, 8)
                .onChange(of: searchText) {
                    viewState.searchText = searchText
                    viewState.currentPage = 0
                    viewState.loadedCardIDs = []
                    Task { await loadInitialCards() }
                }

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
                                    CardStackDestination.stack(
                                        cards: loadedCards,
                                        initialCard: card
                                    ))
                            }
                        )
                    }

                    if viewState.hasMoreContent {
                        ProgressView()
                            .onAppear {
                                if !isLoadingMore {
                                    Task { await loadMoreCards() }
                                }
                            }
                    }
                }
                .padding(PlatformEnvironment.Metrics.defaultPadding)
            }
        }
        .task {
            if loadedCards.isEmpty {
                await loadInitialCards()
            }
        }
        .platformNavigationTitle("Library (\(loadedCards.count) cards)")
    }

    // MARK: - Grid Layout
    private var columns: [GridItem] {
        [
            GridItem(
                .adaptive(
                    minimum: PlatformEnvironment.Metrics.gridMinWidth,
                    maximum: PlatformEnvironment.Metrics.gridMaxWidth),
                spacing: 20)
        ]
    }

    // MARK: - Loading Methods
    @MainActor
    private func loadInitialCards() async {
        var descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
        descriptor.fetchLimit = pageSize

        if !viewState.searchText.isEmpty {
            descriptor.predicate = #Predicate<CardSchemaV1.StereoCard> { card in
                card.titles.contains {
                    $0.text.localizedStandardContains(viewState.searchText)
                }
            }
        }

        do {
            let cards = try modelContext.fetch(descriptor)
            loadedCards = cards
            viewState.loadedCardIDs = cards.map(\.uuid)
            viewState.hasMoreContent = cards.count == pageSize
        } catch {
            print("Failed to load initial cards: \(error)")
        }
    }

    @MainActor
    private func loadMoreCards() async {
        guard viewState.hasMoreContent, !isLoadingMore else { return }

        isLoadingMore = true
        defer { isLoadingMore = false }

        var descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
        descriptor.fetchOffset = viewState.loadedCardIDs.count
        descriptor.fetchLimit = pageSize

        if !viewState.searchText.isEmpty {
            descriptor.predicate = #Predicate<CardSchemaV1.StereoCard> { card in
                card.titles.contains {
                    $0.text.localizedStandardContains(viewState.searchText)
                }
            }
        }

        do {
            let newCards = try modelContext.fetch(descriptor)
            loadedCards.append(contentsOf: newCards)
            viewState.loadedCardIDs.append(contentsOf: newCards.map(\.uuid))
            viewState.hasMoreContent = newCards.count == pageSize
        } catch {
            print("Failed to load more cards: \(error)")
        }
    }
}

#Preview("Library Grid") {
    NavigationStack {
        LibraryGridView(
            modelContext: try! PreviewDataManager.shared.container()
                .mainContext,
            navigationPath: .constant(NavigationPath())
        )
        .withPreviewStore()
        .environment(\.imageLoader, CardImageLoader())
        .frame(width: 1024, height: 400)
    }
}
