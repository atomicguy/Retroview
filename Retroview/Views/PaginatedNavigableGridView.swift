//
//  PaginatedNavigableGridView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/22/24.
//

import SwiftData
import SwiftUI

struct PaginatedNavigableGrid<Header: View>: View {
    @Environment(\.modelContext) private var modelContext
    
    let pageSize: Int
    let emptyTitle: String
    let emptyDescription: String
    @ViewBuilder let header: () -> Header
    
    @State private var currentPage = 0
    @State private var hasMorePages = true
    @State private var isLoadingPage = false
    @State private var cards: [CardSchemaV1.StereoCard] = []
    @State private var selectedCard: CardSchemaV1.StereoCard?
    @State private var navigationPath = NavigationPath()
    
    init(
        pageSize: Int = 100,
        emptyTitle: String,
        emptyDescription: String,
        @ViewBuilder header: @escaping () -> Header
    ) {
        self.pageSize = pageSize
        self.emptyTitle = emptyTitle
        self.emptyDescription = emptyDescription
        self.header = header
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack {
                header()
                
                Group {
                    if cards.isEmpty && !hasMorePages {
                        ContentUnavailableView {
                            Label(emptyTitle, systemImage: "photo.on.rectangle.angled")
                        } description: {
                            Text(emptyDescription)
                        }
                    } else {
                        ScrollView {
                            LazyVStack {
                                CardGridLayout(
                                    cards: cards,
                                    selectedCard: $selectedCard,
                                    onCardSelected: { card in
                                        navigationPath.append(card)
                                    }
                                )
                                
                                if hasMorePages {
                                    ProgressView()
                                        .padding()
                                        .onAppear {
                                            Task {
                                                await loadNextPage()
                                            }
                                        }
                                }
                            }
                        }
                    }
                }
            }
        }
        .task {
            await loadNextPage()
        }
        .refreshable {
            await refresh()
        }
    }
    
    private func loadNextPage() async {
        guard !isLoadingPage else { return }
        isLoadingPage = true
        defer { isLoadingPage = false }
        
        var descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
        descriptor.sortBy = [SortDescriptor(\CardSchemaV1.StereoCard.uuid)]
        descriptor.fetchOffset = currentPage * pageSize
        descriptor.fetchLimit = pageSize
        
        do {
            let newCards = try modelContext.fetch(descriptor)
            await MainActor.run {
                cards.append(contentsOf: newCards)
                hasMorePages = newCards.count == pageSize
                currentPage += 1
            }
        } catch {
            print("Failed to fetch cards: \(error)")
        }
    }
    
    private func refresh() async {
        await MainActor.run {
            currentPage = 0
            cards.removeAll()
            hasMorePages = true
        }
        await loadNextPage()
    }
}
