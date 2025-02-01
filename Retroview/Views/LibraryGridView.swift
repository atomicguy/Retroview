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
    @Environment(\.modelContext) private var modelContext

    @Binding var navigationPath: NavigationPath

    @State private var imageLoader = CardImageLoader()
    @State private var prefetcher: ImagePrefetcher?
    @State private var selectedCard: CardSchemaV1.StereoCard?
    @State private var loadedCards: [CardSchemaV1.StereoCard] = []
    @State private var searchManager: SearchManager
    @State private var currentPage = 0
    @State private var isLoadingMore = false
    @State private var hasMoreContent = true

    private let pageSize = 50

    init(modelContext: ModelContext, navigationPath: Binding<NavigationPath>) {
        self._navigationPath = navigationPath
        self._searchManager = State(
            initialValue: SearchManager(modelContext: modelContext))
    }

    var body: some View {
        VStack(spacing: 0) {
            SearchBar(text: $searchManager.searchText)
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
                                    ))
                            }
                        )
                        .onAppear {
                            if let index = loadedCards.firstIndex(of: card) {
                                prefetcher?.prefetchAroundIndex(
                                    index, in: loadedCards)
                            }
                        }
                        .onDisappear {
                            prefetcher?.cancelAllTasks()
                        }
                        .id(card.id)
                    }

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
                .padding(PlatformEnvironment.Metrics.defaultPadding)
            }
        }
        .platformNavigationTitle("Library (\(searchManager.totalCount) cards)")
        .task {
            searchManager.updateTotalCount(context: modelContext)
        }
        .onChange(of: searchManager.searchText) {
            Task {
                searchManager.updateTotalCount(context: modelContext)
                await loadInitialCards()
            }
        }
        .platformToolbar {
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
        } trailing: {
            Button {
                imageDownloadManager?.startImageDownload()
            } label: {
                Label(
                    "Download Missing Images",
                    systemImage:
                        "arrow.trianglehead.2.clockwise.rotate.90.circle")
            }

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
        var descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
        descriptor.fetchLimit = pageSize
        descriptor.propertiesToFetch = [\.uuid, \.imageFrontId, \.titlePick]

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

        var descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
        descriptor.fetchOffset = loadedCards.count
        descriptor.fetchLimit = pageSize
        descriptor.propertiesToFetch = [\.uuid, \.imageFrontId, \.titlePick]

        if let searchPredicate = searchManager.predicate {
            descriptor.predicate = searchPredicate
        }

        do {
            let newCards = try modelContext.fetch(descriptor)
            hasMoreContent = newCards.count == pageSize
            loadedCards.append(contentsOf: newCards)

            // Prefetch images for new cards
            if let lastVisible = loadedCards.last {
                let index = loadedCards.firstIndex(of: lastVisible) ?? 0
                prefetcher?.prefetchAroundIndex(index, in: loadedCards)
            }
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
