//
//  StoreTransitionManager.swift
//  Retroview
//
//  Created by Adam Schuster on 12/23/24.
//

import Foundation
import SwiftData
import OSLog

actor StoreTransferManager {
    static let shared = StoreTransferManager()
    private let logger = Logger(
        subsystem: "com.example.retroview", category: "StoreTransfer")
    private let archiveManager = StoreArchiveManager()

    enum TransferError: LocalizedError {
        case storeNotFound
        case transferFailed(String)
        case accessDenied
        case invalidStore(String)

        var errorDescription: String? {
            switch self {
            case .storeNotFound:
                return "Could not locate SwiftData store"
            case .transferFailed(let reason):
                return "Store transfer failed: \(reason)"
            case .accessDenied:
                return "Permission denied when accessing the file"
            case .invalidStore(let reason):
                return "Invalid store file: \(reason)"
            }
        }
    }

    private func storeURLs(baseName: String = "MyStereoviews.store") -> [URL] {
        guard
            let appSupport = FileManager.default.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            ).first
        else { return [] }

        let baseURL = appSupport.appendingPathComponent(baseName)
        return [
            baseURL,
            baseURL.appendingPathExtension("shm"),
            baseURL.appendingPathExtension("wal"),
        ]
    }

    func exportStore() async throws -> URL {
        let sourceURLs = storeURLs()
        guard !sourceURLs.isEmpty else {
            throw TransferError.storeNotFound
        }

        // Verify all store files exist
        let existingSourceURLs = sourceURLs.filter {
            FileManager.default.fileExists(atPath: $0.path)
        }

        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(
            at: tempDir,
            withIntermediateDirectories: true
        )

        let exportURL = tempDir.appendingPathComponent(
            "retroview-library.rvstore")

        // Use the new StoreArchiveManager to create the archive
        try await archiveManager.createArchive(
            from: existingSourceURLs,
            to: exportURL
        )

        logger.debug("Exported store to \(exportURL.path)")
        return exportURL
    }

    func importStore(from sourceURL: URL) async throws {
        logger.debug("Starting import from \(sourceURL.path)")

        // Start accessing the security-scoped resource
        guard sourceURL.startAccessingSecurityScopedResource() else {
            throw TransferError.accessDenied
        }
        defer { sourceURL.stopAccessingSecurityScopedResource() }

        // Verify the source file exists and is readable
        guard FileManager.default.isReadableFile(atPath: sourceURL.path) else {
            throw TransferError.accessDenied
        }

        // Create a staging directory for extraction
        let stagingDir = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appendingPathComponent("PendingStore_\(UUID().uuidString)")

        // Create fresh staging directory
        try FileManager.default.createDirectory(
            at: stagingDir,
            withIntermediateDirectories: true,
            attributes: nil
        )

        // Extract the archive
        let extractedURLs = try await archiveManager.extractArchive(
            from: sourceURL,
            to: stagingDir
        )

        // Prepare final destination
        let finalStoreDir = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ).appendingPathComponent("PendingStore")

        // Clean up any existing pending store
        try? FileManager.default.removeItem(at: finalStoreDir)

        // Create fresh pending store directory
        try FileManager.default.createDirectory(
            at: finalStoreDir,
            withIntermediateDirectories: true,
            attributes: nil
        )

        // Copy extracted files to final pending location
        for url in extractedURLs {
            let destinationURL = finalStoreDir.appendingPathComponent(url.lastPathComponent)
            try FileManager.default.copyItem(at: url, to: destinationURL)
        }

        // Create marker file
        try Data("pending".utf8).write(
            to: finalStoreDir.appendingPathComponent(".import-ready")
        )

        logger.debug("Store ready for import, exiting app")
        exit(0)
    }
}
