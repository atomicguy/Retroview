//
//  ImageCacheService.swift
//  Retroview
//
//  Created by Adam Schuster on 12/16/24.
//

import Combine
import CoreGraphics
import SwiftUI

@Observable
final class ImageCacheService: @unchecked Sendable {
    static let shared = ImageCacheService()

    // Cache statistics
    private(set) var totalCached: Int = 0
    private(set) var totalPending: Int = 0

    private let cache = NSCache<NSString, CGImage>()
    private let downloadQueue = OperationQueue()
    private actor PendingDownloads {
        private var downloads = Set<String>()

        func contains(_ id: String) -> Bool {
            downloads.contains(id)
        }

        func insert(_ id: String) {
            downloads.insert(id)
        }

        func remove(_ id: String) {
            downloads.remove(id)
        }

        func count() -> Int {
            downloads.count
        }

        func removeAll() {
            downloads.removeAll()
        }
    }

    private let pendingDownloads = PendingDownloads()

    private init() {
        cache.countLimit = 500
        cache.totalCostLimit = 1024 * 1024 * 100  // 100MB limit
        downloadQueue.maxConcurrentOperationCount = 4
        downloadQueue.qualityOfService = .utility
    }

    func image(for id: String) -> CGImage? {
        cache.object(forKey: id as NSString)
    }

    func cache(_ image: CGImage, for id: String) async {
        await pendingDownloads.remove(id)
        cache.setObject(image, forKey: id as NSString)
        totalCached += 1
        await updatePendingCount()
    }

    func prefetch(for cards: [CardSchemaV1.StereoCard]) {
        Task {
            let imageService = ImageServiceFactory.shared.getService()

            for card in cards {
                guard let imageId = card.imageFrontId else { continue }

                // First check if it's already cached
                if cache.object(forKey: imageId as NSString) != nil {
                    continue
                }

                // Then check if it's already being downloaded
                if await pendingDownloads.contains(imageId) {
                    continue
                }

                // If we get here, we need to download it
                await pendingDownloads.insert(imageId)
                await updatePendingCount()

                // Capture imageId for the async context
                let id = imageId

                downloadQueue.addOperation {
                    Task {
                        do {
                            let thumbnail =
                                try await imageService.loadThumbnail(
                                    id: id,
                                    side: .front,
                                    maxSize: 400
                                )
                            await self.cache(thumbnail, for: id)
                        } catch {
                            await self.pendingDownloads.remove(id)
                            await self.updatePendingCount()
                        }
                    }
                }
            }
        }
    }

    private func updatePendingCount() async {
        totalPending = await pendingDownloads.count()
    }

    func clear() async {
        downloadQueue.cancelAllOperations()
        cache.removeAllObjects()
        await pendingDownloads.removeAll()
        totalCached = 0
        totalPending = 0
    }
}

// Environment key for dependency injection
private struct ImageCacheKey: EnvironmentKey {
    static let defaultValue: ImageCacheService = .shared
}

extension EnvironmentValues {
    var imageCache: ImageCacheService {
        get { self[ImageCacheKey.self] }
        set { self[ImageCacheKey.self] = newValue }
    }
}
