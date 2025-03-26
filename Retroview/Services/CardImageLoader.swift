//
//  CardImageLoader.swift
//  Retroview
//
//  Created by Adam Schuster on 12/22/24.
//

import OSLog
import SwiftData
import SwiftUI

// Actor to safely manage pending image requests
actor ImageRequestManager {
    private var pendingRequests = [String: Task<CGImage?, Error>]()
    
    func getExistingTask(for key: String) -> Task<CGImage?, Error>? {
        return pendingRequests[key]
    }
    
    func registerTask(_ task: Task<CGImage?, Error>, for key: String) {
        pendingRequests[key] = task
    }
    
    func removeTask(for key: String) {
        pendingRequests.removeValue(forKey: key)
    }
}

@Observable
class CardImageLoader {
    private let logger = Logger(
        subsystem: "net.atompowered.retroview",
        category: "CardImageLoader"
    )
    private let cache = ImageCache.shared
    private let loadingQueue = OperationQueue()
    private let requestManager = ImageRequestManager()
    
    init() {
        loadingQueue.maxConcurrentOperationCount = 4 // Limit concurrent downloads
    }

    func loadImage(
        for card: CardSchemaV1.StereoCard, side: CardSide, quality: ImageQuality
    ) async throws -> CGImage? {
        let cacheKey = "\(card.uuid)-\(side.rawValue)-\(quality.rawValue)"
        
        // 1. Check cache first
        if let cachedImage = cache.getImage(forKey: cacheKey) {
            logger.debug("Found image in cache: \(cacheKey)")
            return cachedImage
        }
        
        // 2. Check if there's already a pending request for this image
        if let existingTask = await requestManager.getExistingTask(for: cacheKey) {
            return try await existingTask.value
        }
        
        // 3. Create a new loading task
        let loadTask = Task<CGImage?, Error> {
            defer {
                Task {
                    await requestManager.removeTask(for: cacheKey)
                }
            }
            
            // First check SwiftData stored data
            if let storedImage = await loadStoredImage(for: card, side: side, quality: quality) {
                logger.debug("Found image in SwiftData: \(cacheKey)")
                if let data = await getStoredImageData(for: card, side: side, quality: quality) {
                    cache.storeImage(storedImage, data: data, forKey: cacheKey)
                }
                return storedImage
            }
            
            // Download as last resort
            logger.debug("Downloading image: \(cacheKey)")
            let imageManager = CardImageManager(card: card, side: side, quality: quality)
            guard let url = imageManager.imageURL else { return nil }
            
            // Download image
            let (data, _) = try await URLSession.shared.data(from: url)
            
            guard let provider = CGDataProvider(data: data as CFData),
                let image = CGImage(
                    jpegDataProviderSource: provider,
                    decode: nil,
                    shouldInterpolate: true,
                    intent: .defaultIntent)
            else {
                throw ImageError.invalidImageData
            }
            
            // Store in SwiftData
            await imageManager.storeImageData(data)
            
            // Store in cache
            cache.storeImage(image, data: data, forKey: cacheKey)
            
            return image
        }
        
        // Store the task in our actor
        await requestManager.registerTask(loadTask, for: cacheKey)
        
        return try await loadTask.value
    }

    private func loadStoredImage(
        for card: CardSchemaV1.StereoCard, side: CardSide, quality: ImageQuality
    ) async -> CGImage? {
        // Get stored data based on side and quality
        let imageData = await MainActor.run {
            switch (side, quality) {
            case (.front, .thumbnail):
                return card.frontThumbnailData
            case (.front, _):
                return card.frontStandardData
            case (.back, .thumbnail):
                return card.backThumbnailData
            case (.back, _):
                return card.backStandardData
            }
        }
        
        guard let data = imageData,
            let provider = CGDataProvider(data: data as CFData)
        else { return nil }

        return CGImage(
            jpegDataProviderSource: provider,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent
        )
    }
    
    @MainActor
    private func getStoredImageData(
        for card: CardSchemaV1.StereoCard, side: CardSide, quality: ImageQuality
    ) -> Data? {
        switch (side, quality) {
        case (.front, .thumbnail):
            return card.frontThumbnailData
        case (.front, _):
            return card.frontStandardData
        case (.back, .thumbnail):
            return card.backThumbnailData
        case (.back, _):
            return card.backStandardData
        }
    }

    func clearCache() {
        cache.clearCache()
    }

    enum ImageError: Error {
        case invalidImageData
    }
}
