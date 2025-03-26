//
//  BackroundImageManager.swift
//  Retroview
//
//  Created by Adam Schuster on 12/21/24.
//

import Foundation
import Observation
import OSLog
import SwiftData

@Observable
@MainActor
final class ImageDownloadManager {
    private let modelContext: ModelContext
    private let logger = Logger(
        subsystem: "net.atompowered.retroview", category: "ImageDownload"
    )

    private(set) var totalCardCount: Int = 0
    private(set) var processedCardCount: Int = 0
    private(set) var isDownloading = false
    private var downloadTask: Task<Void, Error>?
    
    // Control the batch size for loading
    private let batchSize = 50
    private let delayBetweenBatches: TimeInterval = 0.5

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // Simplified predicate creation - broken into smaller parts
    private func createNeedsThumbnailPredicate() -> Predicate<CardSchemaV1.StereoCard> {
        // Create separate component predicates
        let needsFrontThumbnail = #Predicate<CardSchemaV1.StereoCard> { card in
            card.imageFrontId != nil && card.frontThumbnailData == nil
        }
        
        let needsBackThumbnail = #Predicate<CardSchemaV1.StereoCard> { card in
            card.imageBackId != nil && card.backThumbnailData == nil
        }
        
        // Combine them with a logical OR
        return #Predicate<CardSchemaV1.StereoCard> { card in
            needsFrontThumbnail.evaluate(card) || needsBackThumbnail.evaluate(card)
        }
    }
    
    // Extracted fetch descriptor creation into a separate function
    private func createFetchDescriptor(offset: Int, limit: Int) -> FetchDescriptor<CardSchemaV1.StereoCard> {
        var descriptor = FetchDescriptor<CardSchemaV1.StereoCard>(
            predicate: createNeedsThumbnailPredicate()
        )
        descriptor.fetchOffset = offset
        descriptor.fetchLimit = limit
        return descriptor
    }
    
    // Extracted batch processing into a separate function
    private func processBatch(cards: [CardSchemaV1.StereoCard], preloader: ImagePreloadService) async throws {
        for card in cards {
            if Task.isCancelled { break }
            
            // Add a small delay between each card to avoid network congestion
            try await Task.sleep(for: .milliseconds(50))
            await preloader.preloadImages(for: card)
            processedCardCount += 1
        }
    }

    func startImageDownload() {
        guard !isDownloading else {
            logger.debug("Image download already in progress")
            return
        }

        isDownloading = true
        processedCardCount = 0

        downloadTask = Task { @MainActor in
            do {
                // Get total count first
                let countDescriptor = FetchDescriptor<CardSchemaV1.StereoCard>(
                    predicate: createNeedsThumbnailPredicate()
                )
                
                totalCardCount = try modelContext.fetchCount(countDescriptor)
                
                if totalCardCount == 0 {
                    logger.debug("No cards need thumbnail downloads")
                    isDownloading = false
                    return
                }
                
                logger.debug("Found \(self.totalCardCount) cards needing thumbnails")
                
                // Process in batches to avoid overloading
                let preloader = ImagePreloadService()
                var currentOffset = 0
                
                while currentOffset < totalCardCount && !Task.isCancelled {
                    // Fetch the next batch
                    let descriptor = createFetchDescriptor(
                        offset: currentOffset,
                        limit: batchSize
                    )
                    
                    let batchCards = try modelContext.fetch(descriptor)
                    
                    if batchCards.isEmpty {
                        break // No more cards to process
                    }
                    
                    // Process this batch
                    try await processBatch(cards: batchCards, preloader: preloader)
                    
                    // Move to next batch
                    currentOffset += batchCards.count
                    
                    // Add a delay between batches
                    if !Task.isCancelled {
                        try await Task.sleep(for: .seconds(delayBetweenBatches))
                    }
                }
            } catch {
                logger.error("Image download failed: \(error.localizedDescription)")
            }

            isDownloading = false
        }
    }

    func cancelDownload() {
        downloadTask?.cancel()
        isDownloading = false
        processedCardCount = 0
        totalCardCount = 0
    }
}
