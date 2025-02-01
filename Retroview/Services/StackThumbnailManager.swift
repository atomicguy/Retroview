//
//  StackThumbnailManager.swift
//  Retroview
//
//  Created by Adam Schuster on 1/20/25.
//

import SwiftData
import SwiftUI

@Observable
final class StackThumbnailManager {
    private let memoryCache: NSCache<NSString, CGImage> = {
        let cache = NSCache<NSString, CGImage>()
        cache.totalCostLimit = 50 * 1024 * 1024  // 50MB limit for stack thumbnails
        return cache
    }()

    private let loadingTasks = TaskManager()
    private let semaphore = AsyncSemaphore(value: 3)
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    @discardableResult 
    func loadThumbnail<T: StackDisplayable & PersistentModel>(for item: T)
        async throws -> CGImage?
    {
        let cacheKey = NSString(string: "stack-\(ObjectIdentifier(item))")

        // Check memory cache first
        if let cached = memoryCache.object(forKey: cacheKey) {
            return cached
        }

        // Use task manager to prevent duplicate generations
        return try await loadingTasks.perform(forKey: cacheKey as String) {
            [self] in
            // Check SwiftData storage
            if let data = item.thumbnailData,
                let provider = CGDataProvider(data: data as CFData),
                let image = CGImage(
                    jpegDataProviderSource: provider,
                    decode: nil,
                    shouldInterpolate: true,
                    intent: .defaultIntent
                )
            {
                cacheImage(image, forKey: cacheKey)
                return image
            }

            // Generate new thumbnail
            await semaphore.wait()

            do {
                let data =
                    try await StackThumbnailGenerator.generateThumbnailData(
                        for: item)

                guard let provider = CGDataProvider(data: data as CFData),
                    let image = CGImage(
                        jpegDataProviderSource: provider,
                        decode: nil,
                        shouldInterpolate: true,
                        intent: .defaultIntent
                    )
                else {
                    await semaphore.signal()
                    return nil
                }

                // Cache in memory
                cacheImage(image, forKey: cacheKey)

                // Store in SwiftData
                await MainActor.run {
                    switch item {
                    case let collection as CollectionSchemaV1.Collection:
                        collection.collectionThumbnail = data
                    case let author as AuthorSchemaV1.Author:
                        author.thumbnailData = data
                    case let subject as SubjectSchemaV1.Subject:
                        subject.thumbnailData = data
                    case let date as DateSchemaV1.Date:
                        date.thumbnailData = data
                    default:
                        break
                    }
                    try? context.save()
                }

                await semaphore.signal()
                return image

            } catch {
                await semaphore.signal()
                throw error
            }
        }
    }

    private func cacheImage(_ image: CGImage, forKey key: NSString) {
        let cost = image.width * image.height * 4
        memoryCache.setObject(image, forKey: key, cost: cost)
    }

    func prefetchThumbnails<T: StackDisplayable & PersistentModel>(
        for items: [T],
        around index: Int,
        window: Int = 2
    ) {
        let startIndex = max(0, index - window)
        let endIndex = min(items.count - 1, index + window)

        for i in startIndex...endIndex {
            let item = items[i]
            Task {
                try? await loadThumbnail(for: item)
            }
        }
    }
}
