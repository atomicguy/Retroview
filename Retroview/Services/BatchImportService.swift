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

@MainActor
class BatchImportService: ObservableObject {
    @Published private(set) var progress: Progress
    private let importService: ImportService
    private let imagePreloader: ImagePreloadService
    private var progressContinuation: AsyncStream<Progress>.Continuation?
    private var cancellationToken: Task<Void, Error>?
    private let batchSize: Int
    private let progressQueue = DispatchQueue(
        label: "com.retroview.importprogress")

    init(modelContext: ModelContext, batchSize: Int = 100) {
        self.progress = Progress(totalUnitCount: 0)
        self.importService = ImportService(modelContext: modelContext)
        self.imagePreloader = ImagePreloadService()
        self.batchSize = batchSize
        self.progress.kind = .file
    }

    func cancelImport() {
        cancellationToken?.cancel()
        progressContinuation?.finish()
    }

    func analyzeDirectory(at url: URL) async throws -> Int {
        guard url.startAccessingSecurityScopedResource() else {
            throw ImportError.securityScopedResourceAccessDenied
        }
        defer { url.stopAccessingSecurityScopedResource() }

        let fileURLs = try FileManager.default.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: .skipsHiddenFiles
        ).filter { $0.pathExtension.lowercased() == "json" }

        return fileURLs.count
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

        // Create new progress instance and immediately notify observers
        progress = Progress(totalUnitCount: Int64(fileURLs.count))
        progressContinuation?.yield(progress)

        var processedCount: Int64 = 0

        cancellationToken = Task {
            // Process in batches
            for batch in stride(from: 0, to: fileURLs.count, by: batchSize) {
                if Task.isCancelled { break }

                let end = min(batch + batchSize, fileURLs.count)
                let batchUrls = Array(fileURLs[batch..<end])

                try await withThrowingTaskGroup(of: Void.self) { group in
                    for fileURL in batchUrls {
                        if Task.isCancelled { break }

                        group.addTask {
                            try await self.importService.importJSON(
                                from: fileURL)

                            // Thread-safe increment and update
                            await self.updateProgress(
                                currentCount: &processedCount)
                        }
                    }

                    try await group.waitForAll()
                }

                // Brief pause between batches
                try await Task.sleep(for: .milliseconds(50))
            }

            if Task.isCancelled {
                throw CancellationError()
            }
        }

        try await cancellationToken?.value
    }

    private func updateProgress(currentCount: inout Int64) async {
        await MainActor.run {
            currentCount += 1
            progress.completedUnitCount = currentCount
            progressContinuation?.yield(progress)
        }
    }

    func getImportReport() -> ImportReport {
        let failedImports = ImportLogger.getFailedImports()
        let report = ImportReport(
            totalProcessed: Int(progress.totalUnitCount),
            successCount: Int(progress.completedUnitCount)
                - failedImports.count,
            failedImports: failedImports
        )
        ImportLogger.clearFailedImports()
        return report
    }
}

enum ImportError: LocalizedError {
    case securityScopedResourceAccessDenied
    case invalidFileFormat(String)
    case processingError(String)
    case cancelled

    var errorDescription: String? {
        switch self {
        case .securityScopedResourceAccessDenied:
            "Access to the selected directory was denied"
        case let .invalidFileFormat(details):
            "Invalid file format: \(details)"
        case let .processingError(details):
            "Error processing import: \(details)"
        case .cancelled:
            "Import cancelled"
        }
    }
}
