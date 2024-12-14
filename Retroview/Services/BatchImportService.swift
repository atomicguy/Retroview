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
    private var progressContinuation: AsyncStream<Progress>.Continuation?
    private var cancellationToken: Task<Void, Error>?

    var progressUpdates: AsyncStream<Progress> {
        AsyncStream { continuation in
            self.progressContinuation = continuation
            continuation.yield(progress)
        }
    }

    init(modelContext: ModelContext) {
        importService = ImportService(modelContext: modelContext)
        progress = Progress(totalUnitCount: 0)
        progress.kind = .file
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

    func importDirectory(at url: URL, batchSize: Int = 10) async throws {
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
        progressContinuation?.yield(progress)

        cancellationToken = Task {
            var processedCount = 0
            var currentIndex = 0

            while currentIndex < fileURLs.count, !Task.isCancelled {
                let batchEnd = min(currentIndex + batchSize, fileURLs.count)
                let batch = fileURLs[currentIndex ..< batchEnd]

                try await withThrowingTaskGroup(of: Void.self) { group in
                    for fileURL in batch {
                        if Task.isCancelled { break }

                        group.addTask {
                            try await self.importService.importJSON(from: fileURL)
                        }
                    }

                    for try await _ in group {
                        processedCount += 1
                        progress.completedUnitCount = Int64(processedCount)
                        progressContinuation?.yield(progress)
                    }
                }

                currentIndex = batchEnd
                if !Task.isCancelled {
                    try await Task.sleep(for: .milliseconds(100))
                }
            }

            if Task.isCancelled {
                throw CancellationError()
            }
        }

        do {
            try await cancellationToken?.value
        } catch is CancellationError {
            // Handle cancellation gracefully
            print("Import cancelled")
            throw ImportError.cancelled
        }

        progressContinuation?.finish()
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
