//
//  StoreImportHandler.swift
//  Retroview
//
//  Created by Adam Schuster on 12/23/24.
//

import Foundation
import OSLog

struct StoreImportHandler {
    private static let logger = Logger(
        subsystem: "com.example.retroview",
        category: "StoreImport"
    )
    
    static func handlePendingImport() {
        do {
            let fileManager = FileManager.default
            let appSupport = try fileManager.url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            
            let pendingDir = appSupport.appendingPathComponent("PendingStore")
            let markerFile = pendingDir.appendingPathComponent(".import-ready")
            
            // Check if we have a pending import
            guard fileManager.fileExists(atPath: markerFile.path) else {
                return
            }
            
            logger.debug("Found pending store import")
            
            // Final store location
            let storeURLs = [
                "MyStereoviews.store",
                "MyStereoviews.store-shm",
                "MyStereoviews.store-wal"
            ].map { appSupport.appendingPathComponent($0) }
            
            // Remove existing store files
            for url in storeURLs {
                try? fileManager.removeItem(at: url)
                logger.debug("Removed existing \(url.lastPathComponent)")
            }
            
            // Collect pending import files
            let pendingFiles = try fileManager
                .contentsOfDirectory(at: pendingDir, includingPropertiesForKeys: nil)
                .filter { $0.lastPathComponent != ".import-ready" }
            
            // Verify SQLite header for main store file
            guard let mainStoreFile = pendingFiles.first(where: {
                $0.pathExtension == "store" || $0.lastPathComponent == "MyStereoviews.store"
            }) else {
                throw ImportError.invalidStore("No main store file found")
            }
            
            guard try verifySQLiteHeader(at: mainStoreFile) else {
                throw ImportError.invalidStore("Invalid SQLite database format")
            }
            
            // Move files to final location
            for file in pendingFiles {
                let destinationURL = appSupport.appendingPathComponent(file.lastPathComponent)
                try fileManager.moveItem(at: file, to: destinationURL)
                logger.debug("Moved \(file.lastPathComponent) to final location")
            }
            
            // Clean up marker and directory
            try? fileManager.removeItem(at: pendingDir)
            
            logger.debug("Import completed successfully")
        } catch {
            logger.error("Failed to handle pending import: \(error.localizedDescription)")
        }
    }
    
    private static func verifySQLiteHeader(at url: URL) throws -> Bool {
        let handle = try FileHandle(forReadingFrom: url)
        defer {
            try? handle.close()
        }
        
        // Read first 16 bytes which should contain the SQLite header
        guard let headerData = try? handle.read(upToCount: 16) else {
            return false
        }
        
        // Check for SQLite file header magic string
        let magicString = "SQLite format 3"
        let magicData = magicString.data(using: .utf8)!
        
        return headerData.starts(with: magicData)
    }
    
    // Error type for specific import-related errors
    enum ImportError: LocalizedError {
        case invalidStore(String)
        
        var errorDescription: String? {
            switch self {
            case .invalidStore(let reason):
                return "Invalid store file: \(reason)"
            }
        }
    }
}
