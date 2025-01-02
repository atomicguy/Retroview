//
//  LibraryGridView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/15/24.
//

import SwiftData
import SwiftUI

struct LibraryGridView: View {
    @Environment(\.importManager) private var importManager
    @Environment(\.imageDownloadManager) private var imageDownloadManager

    let modelContext: ModelContext  // Add explicit modelContext property
    @Binding var navigationPath: NavigationPath
    @State private var selectedCard: CardSchemaV1.StereoCard?
    @State private var loadedCards: [CardSchemaV1.StereoCard] = []
    @State private var searchManager: SearchManager
    @State private var currentPage = 0
    @State private var isLoadingMore = false
    @State private var hasMoreContent = true

    private let pageSize = 100

    init(modelContext: ModelContext, navigationPath: Binding<NavigationPath>) {
        self.modelContext = modelContext
        self._navigationPath = navigationPath
        self._searchManager = State(
            initialValue: SearchManager(modelContext: modelContext))
    }

    var body: some View {
        VStack(spacing: 0) {
            searchBar
            cardGrid
        }
        .navigationTitle("Library (\(searchManager.totalCount) cards)")
        .task {
            // Initial count update
            searchManager.updateTotalCount(context: modelContext)
        }

        .onChange(of: searchManager.searchText) {
            Task {
                searchManager.updateTotalCount(context: modelContext)
                await loadInitialCards()
            }
        }
        .toolbar {
            toolbarContent
        }
    }

    private var searchBar: some View {
        SearchBar(text: $searchManager.searchText)
            .padding(.horizontal)
            .padding(.vertical, 8)
    }

    private var cardGrid: some View {
        ScrollView {
            LazyVGrid(
                columns: columns,
                spacing: PlatformEnvironment.Metrics.gridSpacing
            ) {
                cardItems
                loadingIndicator
            }
            .padding(PlatformEnvironment.Metrics.defaultPadding)
        }
    }

    private var cardItems: some View {
        ForEach(loadedCards) { card in
            SelectableThumbnailView(
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
            .id(card.id)
        }
    }

    private var loadingIndicator: some View {
        Group {
            if hasMoreContent {
                ProgressView()
                    .onAppear {
                        if !isLoadingMore {
                            Task {
                                await loadMoreCards()
                            }
                        }
                    }
            }
        }
    }

    private var toolbarContent: some ToolbarContent {
        Group {
            ToolbarItem(placement: .primaryAction) {
                leadingToolbarItems
            }

            ToolbarItem(placement: .primaryAction) {
                trailingToolbarItems
            }
        }
    }

    private var leadingToolbarItems: some View {
        HStack {
            if let manager = importManager, manager.isImporting {
                ImportProgressIndicator(importManager: manager)
            }

            if let manager = imageDownloadManager, manager.isDownloading {
                BackgroundProgressIndicator(
                    isProcessing: manager.isDownloading,
                    processedCount: manager.processedCardCount,
                    totalCount: manager.missingImageCount,
                    onCancel: { manager.cancelDownload() }
                )
            }
        }
    }

    private var trailingToolbarItems: some View {
        HStack {
            downloadImagesButton
            importMenu

            if !loadedCards.isEmpty {
                BulkCollectionButton(fetchCards: { searchManager.filteredCards }
                )
            }

            DatabaseTransferButton()

            #if DEBUG
                StoreDebugMenu()
            #endif
        }
    }
    private var columns: [GridItem] {
        [
            GridItem(
                .adaptive(
                    minimum: PlatformEnvironment.Metrics.gridMinWidth,
                    maximum: PlatformEnvironment.Metrics.gridMaxWidth
                ), spacing: 20)
        ]
    }

    private var downloadImagesButton: some View {
        Button {
            imageDownloadManager?.startImageDownload()
        } label: {
            Label(
                "Download Missing Images",
                systemImage: "arrow.trianglehead.2.clockwise.rotate.90.circle")
        }
    }

    private var importMenu: some View {
        ImportTypeMenu(
            onImport: { urls, type in
                guard let manager = importManager else { return }

                switch type {
                case .mods:
                    manager.startImport(from: urls)
                case .crops:
                    startCropImport(urls: urls)
                }
            }
        )
    }

    private func startCropImport(urls: [URL]) {
        let cropUpdateService = CropUpdateService(modelContext: modelContext)
        Task {
            do {
                try await cropUpdateService.updateCropsInBatch(from: urls)
            } catch {
                print("Crop import failed: \(error)")
            }
        }
    }

    private func loadInitialCards() async {
        searchManager.updateTotalCount(context: modelContext)

        var descriptor = FetchDescriptor<CardSchemaV1.StereoCard>(
            sortBy: [SortDescriptor(\.uuid)]
        )
        descriptor.fetchLimit = pageSize

        if let searchPredicate = searchManager.predicate {
            descriptor.predicate = searchPredicate
        }

        do {
            loadedCards = try modelContext.fetch(descriptor)
            hasMoreContent = loadedCards.count == pageSize
        } catch {
            print("Failed to load cards: \(error)")
        }
    }

    private func loadMoreCards() async {
        guard hasMoreContent, !isLoadingMore else { return }

        isLoadingMore = true
        defer { isLoadingMore = false }

        var descriptor = FetchDescriptor<CardSchemaV1.StereoCard>(
            sortBy: [SortDescriptor(\.uuid)]
        )
        descriptor.fetchOffset = loadedCards.count
        descriptor.fetchLimit = pageSize

        // Apply search predicate if exists
        if let searchPredicate = searchManager.predicate {
            descriptor.predicate = searchPredicate
        }

        do {
            let newCards = try modelContext.fetch(descriptor)
            hasMoreContent = newCards.count == pageSize
            loadedCards.append(contentsOf: newCards)
        } catch {
            print("Failed to load more cards: \(error)")
        }
    }
}

#Preview("Library Grid") {
    NavigationStack {
        let container = try! PreviewDataManager.shared.container()
        LibraryGridView(
            modelContext: container.mainContext,
            navigationPath: .constant(NavigationPath())
        )
        .withPreviewStore()
        .environment(\.imageLoader, CardImageLoader())
        .frame(width: 1024, height: 400)
    }
}
