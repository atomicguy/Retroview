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
}

extension StoreTransferManager {
    func exportStore() async throws -> URL {
        // Verify store exists
        let sourceURLs = storeURLs(baseName: "MyStereoviews.store")
        guard !sourceURLs.isEmpty else {
            throw TransferError.storeNotFound
        }

        // Create the archive using platform-specific optimizations
        return try await StoreArchiveManager.createArchive()
    }
}


extension StoreTransferManager {
    func importStore(from sourceURL: URL) async throws {
        // Start accessing the security-scoped resource
        guard sourceURL.startAccessingSecurityScopedResource() else {
            throw TransferError.accessDenied
        }
        defer { sourceURL.stopAccessingSecurityScopedResource() }
        
        // Verify the source file exists and is readable
        guard FileManager.default.isReadableFile(atPath: sourceURL.path) else {
            throw TransferError.accessDenied
        }
        
        // Use StoreArchiveManager to handle the import
        try await StoreArchiveManager.importArchive(from: sourceURL)
        
        // App needs to restart to use new store
        exit(0)
    }
}
