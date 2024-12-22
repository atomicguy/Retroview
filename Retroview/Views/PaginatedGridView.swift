//
//  PaginatedGridView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/22/24.
//

import SwiftUI
import SwiftData

struct PaginatedGrid<Content: View>: View {
    @Environment(\.modelContext) private var modelContext
    
    let pageSize: Int
    let content: ([CardSchemaV1.StereoCard]) -> Content
    
    @State private var currentPage = 0
    @State private var hasMorePages = true
    @State private var isLoadingPage = false
    @State private var cards: [CardSchemaV1.StereoCard] = []
    
    init(
        pageSize: Int = 100,
        @ViewBuilder content: @escaping ([CardSchemaV1.StereoCard]) -> Content
    ) {
        self.pageSize = pageSize
        self.content = content
    }
    
    var body: some View {
        ScrollView {
            LazyVStack {
                content(cards)
                
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
