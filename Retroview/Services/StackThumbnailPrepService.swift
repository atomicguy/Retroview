//
//  StackThumbnailPrepService.swift
//  Retroview
//
//  Created by Adam Schuster on 1/29/25.
//

import Foundation
import SwiftData

@Observable
final class StackThumbnailPreparationService {
    private let modelContext: ModelContext
    private let thumbnailManager: StackThumbnailManager
    private let semaphore = AsyncSemaphore(value: 2)
    private var isProcessing = false

    init(modelContext: ModelContext, thumbnailManager: StackThumbnailManager) {
        self.modelContext = modelContext
        self.thumbnailManager = thumbnailManager
    }

    func prepareStackThumbnails() async {
        guard !isProcessing else { return }
        isProcessing = true
        defer { isProcessing = false }

        // Fetch collections without thumbnails
        var descriptor = FetchDescriptor<CollectionSchemaV1.Collection>()
        descriptor.predicate = #Predicate<CollectionSchemaV1.Collection> {
            collection in
            collection.collectionThumbnail == nil
        }
        descriptor.fetchLimit = 50  // Process in batches

        guard let collections = try? modelContext.fetch(descriptor) else {
            return
        }

        await withTaskGroup(of: Void.self) { group in
            for collection in collections {
                group.addTask {
                    await self.semaphore.wait()

                    do {
                        _ = try await self.thumbnailManager.loadThumbnail(
                            for: collection)
                        // Signal after work is complete
                        await self.semaphore.signal()
                    } catch {
                        // Make sure we signal even on error
                        await self.semaphore.signal()
                        print("Failed to generate thumbnail: \(error)")
                    }

                    // Add small delay to prevent overwhelming system
                    try? await Task.sleep(for: .milliseconds(100))
                }
            }
        }
    }
}
