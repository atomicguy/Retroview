//
//  LibraryGridView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/15/24.
//

// LibraryGridView.swift (updated)
import SwiftData
import SwiftUI

@MainActor
struct LibraryGridView: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var navigationPath: NavigationPath
    @State private var selectedCard: CardSchemaV1.StereoCard? = nil
    @State private var loadedCards: [CardSchemaV1.StereoCard] = []
    @State private var isLoadingMore = false
    @State private var searchText = ""
    @State private var searchManager: SearchManager? = nil
    @State private var visibleRange: ClosedRange<Int> = 0...0

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

            VisibilityAwareScrollView(
                showsIndicators: true,
                onScroll: updateVisibleRange
            ) {
                LazyVGrid(
                    columns: columns,
                    spacing: PlatformEnvironment.Metrics.gridSpacing
                ) {
                    ForEach(Array(loadedCards.enumerated()), id: \.element.id) { index, card in
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
                        // Mark as visible for prioritized loading
                        .overlay {
                            if visibleRange.contains(index) {
                                VisibilityMarker()
                            }
                        }
                    }

                    if !isLoadingMore {
                        Color.clear
                            .frame(height: 1)
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
            loadInitialCards()
        }
        .onChange(of: searchManager?.searchText ?? "") {
            loadInitialCards()
        }
    }
    
    private func updateVisibleRange(_ visibility: ScrollVisibility) {
        // Calculate which indices are visible based on scroll position
        let estimatedItemHeight: CGFloat = 200 // Adjust based on your grid item size
        let topIndex = max(0, Int(visibility.topVisible / estimatedItemHeight) * columns.count)
        let bottomIndex = min(loadedCards.count - 1, Int(visibility.bottomVisible / estimatedItemHeight) * columns.count)
        
        // Add buffer zones for smoother scrolling
        let bufferSize = 10
        let newLowerBound = max(0, topIndex - bufferSize)
        let newUpperBound = min(loadedCards.count - 1, bottomIndex + bufferSize)
        
        // Ensure we have a valid range (lower ≤ upper)
        if newLowerBound <= newUpperBound {
            if visibleRange.lowerBound != newLowerBound || visibleRange.upperBound != newUpperBound {
                visibleRange = newLowerBound...newUpperBound
            }
        } else if loadedCards.isEmpty {
            visibleRange = 0...0 // Default empty range
        } else {
            visibleRange = 0...min(20, loadedCards.count - 1) // Default range
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
            // Initialize visible range safely
            if loadedCards.isEmpty {
                visibleRange = 0...0
            } else {
                visibleRange = 0...min(loadedCards.count - 1, 20)
            }
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

// Helper view to mark visible items (doesn't actually render anything)
private struct VisibilityMarker: View {
    var body: some View {
        Color.clear
            .frame(width: 1, height: 1)
            .allowsHitTesting(false)
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
