//
//  BackgroundImportManager.swift
//  Retroview
//
//  Created by Adam Schuster on 12/21/24.
//

import OSLog
import Observation
import SwiftData
import SwiftUI

private let logger = Logger(
    subsystem: "net.atompowered.retroview", category: "Import")

@Observable
@MainActor
final class BackgroundImportManager {
    private let modelContext: ModelContext
    private var importTask: Task<Void, Error>?
    private var preloadTask: Task<Void, Error>?

    private(set) var totalFileCount: Int = 0
    private(set) var importedFileCount: Int = 0
    private(set) var isImporting = false

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func startImport(from urls: [URL]) {
        guard !isImporting else {
            logger.debug("Import already in progress. Ignoring new import request.")
            return
        }
        
        // Reset state explicitly
        totalFileCount = 0
        importedFileCount = 0
        isImporting = true
        
        // Count total files first
        totalFileCount = urls.reduce(0) { count, url in
            guard let files = try? FileManager.default.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: [.isRegularFileKey],
                options: .skipsHiddenFiles
            ) else { return count }
            
            let jsonFiles = files.filter { $0.pathExtension.lowercased() == "json" }
            logger.debug("Found \(jsonFiles.count) JSON files in \(url.lastPathComponent)")
            return count + jsonFiles.count
        }

        logger.debug("Total files to import: \(self.totalFileCount)")

        importTask = Task { @MainActor in
            do {
                try await importFiles(from: urls)
                await startImagePreload()
                
                // Explicitly end import
                importedFileCount = totalFileCount
                isImporting = false
                
                logger.debug("Import completed successfully")
            } catch {
                logger.error("Import failed: \(error.localizedDescription)")
                
                // Ensure import state is reset
                importedFileCount = totalFileCount
                isImporting = false
                
                throw error
            }
        }
    }

    private func importFiles(from urls: [URL]) async throws {
        let importService = ImportService(modelContext: modelContext)
        
        for url in urls {
            guard !Task.isCancelled else {
                logger.info("Import cancelled")
                break
            }
            
            let files = try FileManager.default.contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: [.isRegularFileKey],
                options: .skipsHiddenFiles
            ).filter { $0.pathExtension.lowercased() == "json" }
            
            logger.debug("Processing \(files.count) files in \(url.lastPathComponent)")
            
            // Process in smaller batches to keep UI responsive
            let batchSize = 10
            for batch in stride(from: 0, to: files.count, by: batchSize) {
                let end = min(batch + batchSize, files.count)
                let batchFiles = files[batch..<end]
                
                try await withThrowingTaskGroup(of: Void.self) { group in
                    for fileURL in batchFiles {
                        group.addTask { @MainActor in
                            do {
                                try await importService.importJSON(from: fileURL)
                                
                                // Explicitly update on main actor
                                self.importedFileCount += 1
                                
                                logger.debug(
                                    "Progress updated: \(self.importedFileCount) of \(self.totalFileCount)"
                                )
                            } catch {
                                logger.error(
                                    "Failed to import \(fileURL.lastPathComponent): \(error.localizedDescription)"
                                )
                                // Do not halt entire import if one file fails
                            }
                        }
                    }
                    try await group.waitForAll()
                }
            }
        }
    }

    private func startImagePreload() async {
        preloadTask = Task { @MainActor in
            let imagePreloader = ImagePreloadService()
            let descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()

            // Fetch cards on main actor
            let cards = (try? modelContext.fetch(descriptor)) ?? []

            for card in cards {
                guard !Task.isCancelled else { break }
                await imagePreloader.preloadImages(for: card)
            }
        }
    }

    func cancelImport() {
        logger.debug("Cancelling import")
        importTask?.cancel()
        preloadTask?.cancel()
        
        // Reset import state
        isImporting = false
        totalFileCount = 0
        importedFileCount = 0
    }
}
