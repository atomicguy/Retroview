//
//  CardImageLoader.swift
//  Retroview
//
//  Created by Adam Schuster on 12/22/24.
//

import SwiftData
import SwiftUI

@Observable
class CardImageLoader {
    // Cost-based cache with a 100MB limit
    private let memoryCache: NSCache<NSString, CGImage> = {
        let cache = NSCache<NSString, CGImage>()
        cache.totalCostLimit = 100 * 1024 * 1024  // 100MB
        return cache
    }()

    private let loadingTasks = TaskManager()

    func loadImage(
        for card: CardSchemaV1.StereoCard,
        side: CardSide,
        quality: ImageQuality
    ) async throws -> CGImage? {
        let cacheKey = NSString(
            string: "\(card.uuid)-\(side.rawValue)-\(quality.rawValue)")

        // Check memory cache first
        if let cached = memoryCache.object(forKey: cacheKey) {
            return cached
        }

        // Use task manager to prevent duplicate loads
        return try await loadingTasks.perform(
            forKey: cacheKey as String
        ) { [self] in
            // Check SwiftData storage
            if let imageData = getStoredImageData(
                for: card, side: side, quality: quality),
                let image = try await decodeImage(from: imageData)
            {
                cacheImage(image, forKey: cacheKey)
                return image
            }

            // Download if needed
            guard
                let url = CardImageManager(
                    card: card, side: side, quality: quality
                ).imageURL
            else {
                return nil
            }

            let (data, _) = try await URLSession.shared.data(from: url)
            guard let image = try await decodeImage(from: data) else {
                return nil
            }

            // Cache in memory
            cacheImage(image, forKey: cacheKey)

            // Store in SwiftData
            await MainActor.run {
                storeImageData(data, for: card, side: side, quality: quality)
            }

            return image
        }
    }

    private func cacheImage(_ image: CGImage, forKey key: NSString) {
        // Estimate memory cost (width * height * 4 bytes per pixel)
        let cost = image.width * image.height * 4
        memoryCache.setObject(image, forKey: key, cost: cost)
    }

    private func decodeImage(from data: Data) async throws -> CGImage? {
        return await Task.detached(priority: .utility) {
            guard let provider = CGDataProvider(data: data as CFData) else {
                return nil
            }
            return CGImage(
                jpegDataProviderSource: provider,
                decode: nil,
                shouldInterpolate: true,
                intent: .defaultIntent
            )
        }.value
    }

    // Existing helper methods remain the same
    private func getStoredImageData(
        for card: CardSchemaV1.StereoCard, side: CardSide, quality: ImageQuality
    ) -> Data? {
        switch (side, quality) {
        case (.front, .thumbnail): return card.frontThumbnailData
        case (.front, _): return card.frontStandardData
        case (.back, .thumbnail): return card.backThumbnailData
        case (.back, _): return card.backStandardData
        }
    }

    private func storeImageData(
        _ data: Data, for card: CardSchemaV1.StereoCard, side: CardSide,
        quality: ImageQuality
    ) {
        guard let context = card.modelContext else { return }

        switch (side, quality) {
        case (.front, .thumbnail): card.frontThumbnailData = data
        case (.front, _): card.frontStandardData = data
        case (.back, .thumbnail): card.backThumbnailData = data
        case (.back, _): card.backStandardData = data
        }

        try? context.save()
    }
}

// Helper for managing concurrent loading tasks
actor TaskManager {
    private var tasks: [String: Task<CGImage?, Error>] = [:]

    func perform(
        forKey key: String,
        operation: @escaping () async throws -> CGImage?
    ) async throws -> CGImage? {
        if let existingTask = tasks[key] {
            return try await existingTask.value
        }

        let task = Task {
            defer { tasks.removeValue(forKey: key) }
            return try await operation()
        }

        tasks[key] = task
        return try await task.value
    }
}
