//
//  LibraryGridView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/15/24.
//

import SwiftData
import SwiftUI

struct LibraryGridView: View {
    static let pageSize = 30
    static let prefetchDistance = 10
    
    // Use a more specific sort descriptor and add uniquing
    @Query(
        sort: [
            SortDescriptor(\CardSchemaV1.StereoCard.uuid, order: .forward)
        ],
        animation: .default
    )
    private var allCards: [CardSchemaV1.StereoCard]
    
    @State private var displayedCards: [CardSchemaV1.StereoCard] = []
    @State private var isLoading = false
    @State private var scrollPosition: UUID?
    @State private var showingImport = false
    @State private var showingTransfer = false
    
    @Environment(\.modelContext) private var modelContext
    
    private let columns = [
        GridItem(.adaptive(minimum: 300, maximum: 400), spacing: 20)
    ]
    
    // Computed property to ensure unique cards
    private var uniqueDisplayedCards: [CardSchemaV1.StereoCard] {
        // Use Dictionary to maintain order while ensuring uniqueness by UUID
        let dict = Dictionary(
            uniqueKeysWithValues: displayedCards.map { ($0.uuid, $0) }
        )
        return Array(dict.values)
    }
    
    var body: some View {
        NavigationStack {
            GridContent(
                displayedCards: uniqueDisplayedCards,  // Use unique cards
                allCards: allCards,
                isLoading: isLoading,
                scrollPosition: $scrollPosition,
                onLoadMore: loadMoreContent
            )
            .navigationTitle("Library (\(allCards.count) cards)")
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button {
                        showingImport = true
                    } label: {
                        Label("Import", systemImage: "square.and.arrow.down")
                    }
                    
                    Button {
                        showingTransfer = true
                    } label: {
                        Label("Transfer", systemImage: "arrow.up.arrow.down")
                    }
                    
                    #if DEBUG
                    StoreDebugMenu()
                    #endif
                }
            }
        }
        .task {
            loadMoreContent()
        }
        .sheet(isPresented: $showingImport) {
            ImportView(modelContext: modelContext)
        }
        .sheet(isPresented: $showingTransfer) {
            DatabaseTransferView()
        }
        .refreshable {
            await refresh()
        }
    }
    
    private func loadMoreContent() {
        guard !isLoading else { return }
        
        Task {
            isLoading = true
            defer { isLoading = false }
            
            let startIndex = displayedCards.count
            let endIndex = min(startIndex + Self.pageSize, allCards.count)
            
            guard startIndex < endIndex else { return }
            
            try? await Task.sleep(for: .milliseconds(50))
            
            await MainActor.run {
                let newCards = Array(allCards[startIndex..<endIndex])
                // Check for and log any duplicate UUIDs in debug builds
                #if DEBUG
                let uuids = newCards.map { $0.uuid }
                let duplicates = Dictionary(grouping: uuids, by: { $0 })
                    .filter { $1.count > 1 }
                
                if !duplicates.isEmpty {
                    print("⚠️ Warning: Found duplicate UUIDs in cards:", duplicates.keys)
                }
                #endif
                
                // Append new cards, avoiding duplicates
                let existingUUIDs = Set(displayedCards.map { $0.uuid })
                let uniqueNewCards = newCards.filter { !existingUUIDs.contains($0.uuid) }
                displayedCards.append(contentsOf: uniqueNewCards)
                
                ImageCacheService.shared.prefetch(for: uniqueNewCards)
            }
        }
    }
    
    private func refresh() async {
        displayedCards = []
        isLoading = false
        loadMoreContent()
    }
}

// MARK: - Supporting Views
private struct GridContent: View {
    let displayedCards: [CardSchemaV1.StereoCard]
    let allCards: [CardSchemaV1.StereoCard]
    let isLoading: Bool
    @Binding var scrollPosition: UUID?
    let onLoadMore: () -> Void
    
    private let columns = [
        GridItem(.adaptive(minimum: 300, maximum: 400), spacing: 20)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(displayedCards) { card in
                    ThumbnailView(card: card)
                        .id(card.id)
                        .onAppear {
                            if card == displayedCards.last ||
                                displayedCards.suffix(LibraryGridView.prefetchDistance).contains(card) {
                                onLoadMore()
                            }
                        }
                }
                
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .padding()
        }
        .scrollPosition(id: $scrollPosition)
        .overlay(alignment: .bottom) {
            if !displayedCards.isEmpty {
                ProgressOverlay(current: displayedCards.count, total: allCards.count)
            }
        }
    }
}

private struct ProgressOverlay: View {
    let current: Int
    let total: Int
    
    var body: some View {
        HStack {
            Text("\(current) of \(total)")
                .monospacedDigit()
            Text("•")
            Text("\((Double(current) / Double(total) * 100).formatted(.number.precision(.fractionLength(1))))%")
                .monospacedDigit()
        }
        .font(.caption)
        .padding(8)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .padding(.bottom)
    }
}

#Preview {
    LibraryGridView()
        .withPreviewStore()
        .frame(width: 800, height: 600)
}
