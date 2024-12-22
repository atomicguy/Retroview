//
//  BackroundImageManager.swift
//  Retroview
//
//  Created by Adam Schuster on 12/21/24.
//

import Foundation
import OSLog
import Observation
import SwiftData

@Observable
@MainActor
final class ImageDownloadManager {
    private let modelContext: ModelContext
    private let urlSession: URLSession
    private let logger = Logger(
        subsystem: "net.atompowered.retroview", category: "ImageDownload")

    private(set) var totalCardCount: Int = 0
    private(set) var processedCardCount: Int = 0
    private(set) var missingImageCount: Int = 0
    private(set) var isDownloading = false
    private var downloadTask: Task<Void, Error>?

    // Concurrency control
    private let semaphore: AsyncSemaphore

    init(modelContext: ModelContext, urlSession: URLSession = .shared) {
        self.modelContext = modelContext
        self.urlSession = urlSession
        // Limit to 5 concurrent downloads
        self.semaphore = AsyncSemaphore(value: 5)
    }

    func startImageDownload() {
        guard !isDownloading else {
            logger.debug("Image download already in progress")
            return
        }

        isDownloading = true
        processedCardCount = 0

        downloadTask = Task {
            do {
                try await downloadMissingImages()
            } catch {
                logger.error(
                    "Image download failed: \(error.localizedDescription)")
            }

            isDownloading = false
            processedCardCount = totalCardCount
        }
    }

    private func downloadMissingImages() async throws {
        // Define the conditions separately for clarity
        let needsFrontThumbnail = #Predicate<CardSchemaV1.StereoCard> { card in
            card.imageFrontId != nil && card.frontThumbnailData == nil
        }
        
        let needsBackThumbnail = #Predicate<CardSchemaV1.StereoCard> { card in
            card.imageBackId != nil && card.backThumbnailData == nil
        }
        
        // Combine the predicates
        let descriptor = FetchDescriptor<CardSchemaV1.StereoCard>(
            predicate: #Predicate<CardSchemaV1.StereoCard> { card in
                needsFrontThumbnail.evaluate(card) || needsBackThumbnail.evaluate(card)
            }
        )

        let cardsNeedingImages = try modelContext.fetch(descriptor)
        totalCardCount = cardsNeedingImages.count
        missingImageCount = totalCardCount
        processedCardCount = 0

        let preloader = ImagePreloadService()

        try await withThrowingTaskGroup(of: Void.self) { group in
            for card in cardsNeedingImages {
                group.addTask { @MainActor in
                    guard !Task.isCancelled else { return }

                    // Use semaphore to limit concurrent downloads
                    await self.semaphore.wait()

                    do {
                        try? await Task.sleep(for: .milliseconds(100))  // Small delay between requests

                        await preloader.preloadImages(for: card)

                        // Increment processed count on MainActor
                        self.processedCardCount += 1
                    }

                    // Always signal after the download attempt
                    await self.semaphore.signal()
                }
            }

            try await group.waitForAll()
        }
    }

    func cancelDownload() {
        downloadTask?.cancel()
        isDownloading = false
        processedCardCount = 0
        totalCardCount = 0
        missingImageCount = 0
    }
}

// Simple async semaphore for concurrency control
actor AsyncSemaphore {
    private let maxConcurrent: Int
    private var currentCount = 0
    private var waiters: [CheckedContinuation<Void, Never>] = []

    init(value: Int) {
        self.maxConcurrent = value
    }

    func wait() async {
        while currentCount >= maxConcurrent {
            await withCheckedContinuation { continuation in
                waiters.append(continuation)
            }
        }
        currentCount += 1
    }

    func signal() {
        currentCount -= 1

        guard let next = waiters.popLast() else { return }
        next.resume()
    }
}
