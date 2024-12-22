//
//  BatchImportService.swift
//  Retroview
//
//  Created by Adam Schuster on 11/27/24.
//

import Foundation
import SwiftData

// MARK: - BatchConfiguration

struct BatchConfiguration {
    let batchSize: Int
    let totalFiles: Int
    var currentBatch: Int = 0

    var remainingFiles: Int {
        totalFiles - (currentBatch * batchSize)
    }

    var nextBatchSize: Int {
        min(batchSize, remainingFiles)
    }

    var isComplete: Bool {
        remainingFiles <= 0
    }
}

// MARK: - ImportProgress

struct ImportProgress {
    let filesProcessed: Int
    let totalFiles: Int
    let currentBatch: Int
    let totalBatches: Int
    let isComplete: Bool

    var percentComplete: Double {
        guard totalFiles > 0 else { return 0 }
        return Double(filesProcessed) / Double(totalFiles)
    }
}

// MARK: - BatchImportService

@Observable @MainActor
final class BatchImportService {
    private(set) var progress: Progress
    private(set) var importReport: ImportReport?
    private(set) var isProcessing = false
    private let importService: ImportService
    private let imagePreloader: ImagePreloadService
    private let batchSize: Int

    init(modelContext: ModelContext, batchSize: Int = 500) {
        self.progress = Progress(totalUnitCount: 0)
        self.importService = ImportService(modelContext: modelContext)
        self.imagePreloader = ImagePreloadService()
        self.batchSize = batchSize
        self.progress.kind = .file
    }

    func cancelImport() {
        isProcessing = false
        progress.cancel()
    }

    func analyzeDirectory(at url: URL) async throws -> Int {
        guard url.startAccessingSecurityScopedResource() else {
            throw ImportError.securityScopedResourceAccessDenied
        }
        defer { url.stopAccessingSecurityScopedResource() }

        return try FileManager.default.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: .skipsHiddenFiles
        ).filter { $0.pathExtension.lowercased() == "json" }
            .count
    }

    func importDirectory(at url: URL) async throws {
        guard url.startAccessingSecurityScopedResource() else {
            throw ImportError.securityScopedResourceAccessDenied
        }
        defer { url.stopAccessingSecurityScopedResource() }

        let fileURLs = try FileManager.default.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: .skipsHiddenFiles
        ).filter { $0.pathExtension.lowercased() == "json" }

        progress = Progress(totalUnitCount: Int64(fileURLs.count))

        // Process in batches
        for batch in stride(from: 0, to: fileURLs.count, by: batchSize) {
            try Task.checkCancellation()

            let end = min(batch + batchSize, fileURLs.count)
            let batchUrls = Array(fileURLs[batch..<end])

            try await withThrowingTaskGroup(of: Void.self) { group in
                for fileURL in batchUrls {
                    group.addTask {
                        try await self.importService.importJSON(from: fileURL)
                        await self.updateProgress()
                    }
                }

                try await group.waitForAll()
            }

            // Brief pause between batches
            try await Task.sleep(for: .milliseconds(50))
        }

        // Generate final report
        importReport = ImportReport(
            totalProcessed: Int(progress.totalUnitCount),
            successCount: Int(progress.completedUnitCount)
                - ImportLogger.getFailedImports().count,
            failedImports: ImportLogger.getFailedImports()
        )
        ImportLogger.clearFailedImports()
    }

    private func updateProgress() {
        progress.completedUnitCount += 1
    }
}

enum ImportError: LocalizedError {
    case securityScopedResourceAccessDenied
    case invalidFileFormat(String)
    case processingError(String)
    case noJsonFiles(directory: String)
    case cancelled

    var errorDescription: String? {
        switch self {
        case .securityScopedResourceAccessDenied:
            "Access to the selected directory was denied"
        case let .invalidFileFormat(details):
            "Invalid file format: \(details)"
        case let .processingError(details):
            "Error processing import: \(details)"
        case .noJsonFiles(let directory):
            "No JSON files found in directory: \(directory)"
        case .cancelled:
            "Import cancelled"
        }
    }
}
