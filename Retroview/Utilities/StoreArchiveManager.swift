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

import Foundation
import SwiftData
import UniformTypeIdentifiers

actor StoreArchiveManager {
    enum ArchiveError: LocalizedError {
        case directoryNotFound
        case archiveCreationFailed(String)
        case importFailed(String)
        case invalidArchive(String)
        
        var errorDescription: String? {
            switch self {
            case .directoryNotFound:
                "Could not locate Application Support directory"
            case .archiveCreationFailed(let reason):
                "Failed to create archive: \(reason)"
            case .importFailed(let reason):
                "Failed to import archive: \(reason)"
            case .invalidArchive(let reason):
                "Invalid archive format: \(reason)"
            }
        }
    }
    
    static func createArchive() async throws -> URL {
        guard let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else {
            throw ArchiveError.directoryNotFound
        }
        
        // Create temporary directory for staging
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(
            at: tempDir,
            withIntermediateDirectories: true
        )
        
        let archiveURL = tempDir.appendingPathComponent("retroview-backup.rvstore")
        
        // Copy store files to staging directory
        let sourceStoreURL = appSupport.appendingPathComponent("MyStereoviews.store")
        let storeFiles = [
            sourceStoreURL,
            sourceStoreURL.appendingPathExtension("shm"),
            sourceStoreURL.appendingPathExtension("wal")
        ]
        
        // Create archive data
        var archiveData = Data()
        
        // Add identifier header
        let header = "RVSTORE1".data(using: .utf8)!
        archiveData.append(header)
        
        // Add each file with its metadata
        for sourceURL in storeFiles {
            guard FileManager.default.fileExists(atPath: sourceURL.path) else { continue }
            
            let fileData = try Data(contentsOf: sourceURL)
            let filename = sourceURL.lastPathComponent
            
            // Add filename length and filename
            let filenameData = filename.data(using: .utf8)!
            let filenameLength = UInt32(filenameData.count)
            archiveData.append(withUnsafeBytes(of: filenameLength) { Data($0) })
            archiveData.append(filenameData)
            
            // Add file data length and data
            let dataLength = UInt64(fileData.count)
            archiveData.append(withUnsafeBytes(of: dataLength) { Data($0) })
            archiveData.append(fileData)
        }
        
        // Write the archive
        try archiveData.write(to: archiveURL)
        
        return archiveURL
    }
    
    static func importArchive(from sourceURL: URL) async throws {
        guard let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else {
            throw ArchiveError.directoryNotFound
        }
        
        let pendingDir = appSupport.appendingPathComponent("PendingStore")
        
        // Clean up any existing pending imports
        try? FileManager.default.removeItem(at: pendingDir)
        
        // Create fresh pending directory
        try FileManager.default.createDirectory(
            at: pendingDir,
            withIntermediateDirectories: true
        )
        
        // Read archive data
        let archiveData = try Data(contentsOf: sourceURL)
        
        // Verify header
        let headerLength = "RVSTORE1".count
        guard archiveData.count >= headerLength,
              let header = String(
                data: archiveData.prefix(headerLength),
                encoding: .utf8
              ),
              header == "RVSTORE1"
        else {
            throw ArchiveError.invalidArchive("Invalid archive format")
        }
        
        // Parse archive data
        var position = headerLength
        
        while position < archiveData.count {
            // Read filename length
            let filenameLengthData = archiveData.subdata(
                in: position..<position + 4)
            let filenameLength = filenameLengthData.withUnsafeBytes {
                $0.load(as: UInt32.self)
            }
            position += 4
            
            // Read filename
            let filenameData = archiveData.subdata(
                in: position..<position + Int(filenameLength))
            guard let filename = String(data: filenameData, encoding: .utf8) else {
                throw ArchiveError.invalidArchive("Invalid filename encoding")
            }
            position += Int(filenameLength)
            
            // Read file data length
            let dataLengthData = archiveData.subdata(
                in: position..<position + 8)
            let dataLength = dataLengthData.withUnsafeBytes {
                $0.load(as: UInt64.self)
            }
            position += 8
            
            // Read file data
            let fileData = archiveData.subdata(
                in: position..<position + Int(dataLength))
            position += Int(dataLength)
            
            // Write file
            let fileURL = pendingDir.appendingPathComponent(filename)
            try fileData.write(to: fileURL)
        }
        
        // Create marker file
        try Data("pending".utf8).write(
            to: pendingDir.appendingPathComponent(".import-ready")
        )
    }
}
