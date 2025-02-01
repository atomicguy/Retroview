//
//  GridLoadingManager.swift
//  Retroview
//
//  Created by Adam Schuster on 1/26/25.
//

import SwiftData

@Observable
class GridLoadingManager {
    private let modelContext: ModelContext
    private let batchSize = 50
    private var currentPage = 0
    private var isFetching = false
    
    private(set) var cards: [CardSchemaV1.StereoCard] = []
    private(set) var hasMoreContent = true
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func loadNextBatchIfNeeded() async {
        guard !isFetching && hasMoreContent else { return }
        
        isFetching = true
        defer { isFetching = false }
        
        var descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
        descriptor.fetchLimit = batchSize
        descriptor.fetchOffset = currentPage * batchSize
        descriptor.propertiesToFetch = [\.uuid, \.imageFrontId, \.titlePick]
        
        do {
            let newCards = try modelContext.fetch(descriptor)
            await MainActor.run {
                cards.append(contentsOf: newCards)
                currentPage += 1
                hasMoreContent = newCards.count == batchSize
            }
        } catch {
            print("Failed to fetch cards: \(error)")
        }
    }
}
