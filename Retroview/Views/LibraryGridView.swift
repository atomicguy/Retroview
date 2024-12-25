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
    @Environment(\.importManager) private var importManager
    @Environment(\.imageDownloadManager) private var imageDownloadManager
    
    @Binding var navigationPath: NavigationPath
    @State private var selectedCard: CardSchemaV1.StereoCard?
    @State private var loadedCards: [CardSchemaV1.StereoCard] = []
    @State private var currentPage = 0
    @State private var isLoadingMore = false
    @State private var hasMoreContent = true
    @State private var showingStoreTransfer = false
    @State private var isImporting = false
    
    private let pageSize = 100
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: PlatformEnvironment.Metrics.gridSpacing) {
                ForEach(loadedCards) { card in
                    SelectableThumbnailView(
                        card: card,
                        isSelected: card.id == selectedCard?.id,
                        onSelect: { selectedCard = card },
                        onDoubleClick: {
                            navigationPath.append(card)
                        }
                    )
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
        .task {
            await loadInitialCards()
        }
        // Keep existing toolbar items and navigation title
        .platformNavigationTitle("Library", displayMode: .large)
        .platformToolbar {
            // Leading toolbar items
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
        } trailing: {
            // Trailing toolbar items
            HStack {
                downloadImagesButton
                importMenu
                DatabaseTransferButton()

                #if DEBUG
                    StoreDebugMenu()
                #endif
            }
        }
    }
    
    private var columns: [GridItem] {
        [GridItem(.adaptive(
            minimum: PlatformEnvironment.Metrics.gridMinWidth,
            maximum: PlatformEnvironment.Metrics.gridMaxWidth
        ), spacing: 20)]
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
        var descriptor = FetchDescriptor<CardSchemaV1.StereoCard>(
            sortBy: [SortDescriptor(\.uuid)]
        )
        descriptor.fetchLimit = pageSize
        
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
        
        do {
            let newCards = try modelContext.fetch(descriptor)
            hasMoreContent = newCards.count == pageSize
            loadedCards.append(contentsOf: newCards)
        } catch {
            print("Failed to load more cards: \(error)")
        }
    }
}
