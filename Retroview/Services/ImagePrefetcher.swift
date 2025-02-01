//
//  ImagePrefetcher.swift
//  Retroview
//
//  Created by Adam Schuster on 1/26/25.
//

import Foundation

@Observable
final class ImagePrefetcher {
    private let prefetchWindow = 5  // Items ahead/behind to prefetch
    private let maxConcurrentLoads = 3
    private let imageLoader: CardImageLoader
    private let semaphore: AsyncSemaphore
    private var activeTasks: [UUID: Task<Void, Never>] = [:]

    // Add priority system
    private var highPriorityQueue: Set<UUID> = []
    private var lowPriorityQueue: Set<UUID> = []

    init(imageLoader: CardImageLoader) {
        self.imageLoader = imageLoader
        self.semaphore = AsyncSemaphore(value: maxConcurrentLoads)
    }

    func prefetchAroundIndex(
        _ index: Int, in cards: [CardSchemaV1.StereoCard],
        isVisible: Bool = true
    ) {
        guard !cards.isEmpty else { return }

        // Calculate range to prefetch
        let startIndex = max(0, index - prefetchWindow)
        let endIndex = min(cards.count - 1, index + prefetchWindow)

        // Cancel tasks that are no longer needed
        cancelTasksOutsideRange(startIndex...endIndex, cards: cards)

        for i in startIndex...endIndex {
            let card = cards[i]

            // Skip if already being processed
            guard activeTasks[card.uuid] == nil else { continue }

            // Add to appropriate queue based on visibility
            if isVisible {
                highPriorityQueue.insert(card.uuid)
                lowPriorityQueue.remove(card.uuid)
            } else {
                if !highPriorityQueue.contains(card.uuid) {
                    lowPriorityQueue.insert(card.uuid)
                }
            }

            startPrefetchTask(for: card, isHighPriority: isVisible)
        }
    }

    private func startPrefetchTask(
        for card: CardSchemaV1.StereoCard, isHighPriority: Bool
    ) {
        activeTasks[card.uuid] = Task {
            // Add delay for low priority tasks to prevent overwhelming system
            if !isHighPriority {
                try? await Task.sleep(for: .milliseconds(100))
            }

            await semaphore.wait()

            do {
                try Task.checkCancellation()
                _ = try await imageLoader.loadImage(
                    for: card,
                    side: .front,
                    quality: .thumbnail
                )

                // Signal after the work is done
                await semaphore.signal()
            } catch {
                // Make sure we still signal even if there's an error
                await semaphore.signal()
                // Handle errors silently for prefetching
            }

            activeTasks[card.uuid] = nil

            if isHighPriority {
                highPriorityQueue.remove(card.uuid)
            } else {
                lowPriorityQueue.remove(card.uuid)
            }
        }
    }

    func cancelAllTasks() {
        activeTasks.values.forEach { $0.cancel() }
        activeTasks.removeAll()
        highPriorityQueue.removeAll()
        lowPriorityQueue.removeAll()
    }

    private func cancelTasksOutsideRange(
        _ range: ClosedRange<Int>, cards: [CardSchemaV1.StereoCard]
    ) {
        for (id, task) in activeTasks {
            if let index = cards.firstIndex(where: { $0.uuid == id }),
                !range.contains(index)
            {
                task.cancel()
                activeTasks.removeValue(forKey: id)
                highPriorityQueue.remove(id)
                lowPriorityQueue.remove(id)
            }
        }
    }
}
