//
//  DailyDiscoveryManager.swift
//  Retroview
//
//  Created by Adam Schuster on 3/24/25.
//

import SwiftData
import SwiftUI
import OSLog

@Observable
@MainActor
class DailyDiscoveryManager {
    private let modelContext: ModelContext
    private let logger = Logger(subsystem: "net.atompowered.retroview", category: "DailyDiscovery")
    private let cardLimit = 50
    
    private(set) var dailyCards: [CardSchemaV1.StereoCard] = []
    private(set) var lastRefreshDate: Date?
    private(set) var isLoading = false
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func loadDailyCards() async {
        guard !isLoading else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        // Check if we need to refresh based on date
        if let lastRefresh = lastRefreshDate, Calendar.current.isDateInToday(lastRefresh), !dailyCards.isEmpty {
            logger.debug("Using cached daily selection from today")
            return
        }
        
        // Get a new random selection
        await refreshDailySelection()
    }
    
    private func refreshDailySelection() async {
        logger.debug("Refreshing daily card selection")
        
        do {
            // First, count total cards to know our range
            let countDescriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
            let totalCardCount = try modelContext.fetchCount(countDescriptor)
            
            guard totalCardCount > 0 else {
                logger.error("No cards available for daily selection")
                return
            }
            
            // Generate random indices
            var randomIndices = Set<Int>()
            let selectionCount = min(cardLimit, totalCardCount)
            
            while randomIndices.count < selectionCount {
                randomIndices.insert(Int.random(in: 0..<totalCardCount))
            }
            
            // Fetch random selections in batches to avoid loading all cards
            var dailySelection: [CardSchemaV1.StereoCard] = []
            
            for index in randomIndices {
                var descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
                descriptor.fetchOffset = index
                descriptor.fetchLimit = 1
                
                if let card = try modelContext.fetch(descriptor).first {
                    dailySelection.append(card)
                }
            }
            
            // Update state
            dailyCards = dailySelection
            lastRefreshDate = Date()
            
            logger.debug("Daily selection refreshed with \(dailySelection.count) cards")
        } catch {
            logger.error("Failed to refresh daily selection: \(error.localizedDescription)")
        }
    }
}
