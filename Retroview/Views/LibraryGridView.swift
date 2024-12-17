//
//  LibraryGridView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/15/24.
//

import SwiftData
import SwiftUI

struct LibraryGridView: View {
    static let pageSize = 30  // Smaller initial load

    // Split into two queries - one for count, one for paged data
    @Query(sort: \CardSchemaV1.StereoCard.uuid)
    private var allCards: [CardSchemaV1.StereoCard]

    @State private var displayedCards: [CardSchemaV1.StereoCard] = []
    @State private var isLoading = false

    @Environment(\.modelContext) private var modelContext
    @State private var showingImport = false
    @State private var showingTransfer = false

    private let columns = [
        GridItem(.adaptive(minimum: 300, maximum: 400), spacing: 20)
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(displayedCards) { card in
                        CardThumbnail(card: card)
                            .onAppear {
                                // If this is one of the last few items, load more
                                if card == displayedCards.last
                                    || displayedCards.suffix(5).contains(card)
                                {
                                    loadMoreContent()
                                }
                            }
                    }

                    // Loading indicator at bottom
                    if isLoading {
                        ProgressView()
                            .padding()
                    }
                }
                .padding()
            }
            .navigationTitle("Library (\(allCards.count) cards)")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    HStack(spacing: 12) {
                        Button {
                            showingImport = true
                        } label: {
                            Label(
                                "Import", systemImage: "square.and.arrow.down")
                        }

                        Button {
                            showingTransfer = true
                        } label: {
                            Label(
                                "Transfer", systemImage: "arrow.up.arrow.down")
                        }

                        #if DEBUG
                            StoreDebugMenu()
                        #endif
                    }
                }
            }
        }
        .task {
            // Initial load
            loadMoreContent()
        }
        .sheet(isPresented: $showingImport) {
            ImportView(modelContext: modelContext)
        }
        .sheet(isPresented: $showingTransfer) {
            DatabaseTransferView()
        }
        .refreshable {
            // Pull to refresh support
            displayedCards = []
            loadMoreContent()
        }
    }

    private let preloadWindow = 10  // Number of items to preload

    private func loadMoreContent() {
        guard !isLoading else { return }

        Task {
            isLoading = true
            defer { isLoading = false }

            let startIndex = displayedCards.count
            let endIndex = min(
                startIndex + Self.pageSize + preloadWindow, allCards.count)

            guard startIndex < endIndex else { return }

            // Add small delay to prevent UI hitching
            try? await Task.sleep(for: .milliseconds(50))

            await MainActor.run {
                let newCards = allCards[startIndex..<endIndex]
                displayedCards.append(contentsOf: newCards)
            }
        }
    }
}

#Preview {
    LibraryGridView()
        .withPreviewStore()
        .frame(width: 800, height: 600)
}
