//
//  StoreArchiveManager.swift
//  Retroview
//
//  Created by Adam Schuster on 12/23/24.
//

import Foundation
import Compression
import OSLog

enum StoreArchiveError: LocalizedError {
    case compressionFailed(String)
    case decompressionFailed(String)
    case invalidArchive
    
    var errorDescription: String? {
        switch self {
        case .compressionFailed(let reason):
            return "Compression failed: \(reason)"
        case .decompressionFailed(let reason):
            return "Decompression failed: \(reason)"
        case .invalidArchive:
            return "The archive is not a valid Retroview store archive"
        }
    }
}

actor StoreArchiveManager {
    private let logger = Logger(
        subsystem: "net.atompowered.retroview",
        category: "StoreArchive"
    )
    
    func createArchive(
        from sourceURLs: [URL],
        to destinationURL: URL
    ) throws {
        // Verify files exist
        guard sourceURLs.allSatisfy({ FileManager.default.fileExists(atPath: $0.path) }) else {
            throw StoreArchiveError.compressionFailed("Source files are missing")
        }
        
        // Create temporary directory for archiving
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
        
        // Copy files to temp directory
        for sourceURL in sourceURLs {
            let destURL = tempDir.appendingPathComponent(sourceURL.lastPathComponent)
            try FileManager.default.copyItem(at: sourceURL, to: destURL)
        }
        
        // Create archive
        let archiver = try Archiver(url: destinationURL)
        try archiver.addDirectory(at: tempDir)
        try archiver.finalize()
        
        // Clean up temporary directory
        try? FileManager.default.removeItem(at: tempDir)
    }
    
    func extractArchive(from archiveURL: URL, to destinationURL: URL) throws -> [URL] {
        // Verify archive exists
        guard FileManager.default.fileExists(atPath: archiveURL.path) else {
            throw StoreArchiveError.invalidArchive
        }
        
        // Create destination directory
        try FileManager.default.createDirectory(
            at: destinationURL,
            withIntermediateDirectories: true
        )
        
        let extractor = try Extractor(url: archiveURL)
        let extractedURLs = try extractor.extractAll(to: destinationURL)
        
        return extractedURLs
    }
}

// Lightweight wrapper around compression for more robust archiving
private struct Archiver {
    private let destinationURL: URL
    
    init(url: URL) throws {
        self.destinationURL = url
    }
    
    func addDirectory(at directoryURL: URL) throws {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/zip")
        task.arguments = ["-r", destinationURL.path, "."]
        task.currentDirectoryURL = directoryURL
        
        try task.run()
        task.waitUntilExit()
        
        guard task.terminationStatus == 0 else {
            throw StoreArchiveError.compressionFailed("Zip process failed")
        }
    }
    
    func finalize() throws {
        // Additional verification or metadata could be added here
    }
}

private struct Extractor {
    private let archiveURL: URL
    
    init(url: URL) throws {
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw StoreArchiveError.invalidArchive
        }
        self.archiveURL = url
    }
    
    func extractAll(to destinationURL: URL) throws -> [URL] {
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
        task.arguments = [archiveURL.path, "-d", destinationURL.path]
        
        try task.run()
        task.waitUntilExit()
        
        guard task.terminationStatus == 0 else {
            throw StoreArchiveError.decompressionFailed("Unzip process failed")
        }
        
        // Return list of extracted files
        return try FileManager.default
            .contentsOfDirectory(at: destinationURL, includingPropertiesForKeys: nil)
    }
}
