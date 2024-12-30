//
//  PreviewApplication+Cards.swift
//  Retroview
//
//  Created by Adam Schuster on 12/29/24.
//

import OSLog
import QuickLook
import RealityKit
import SwiftUI

import SwiftUI
import OSLog

extension PreviewApplication {
    private static let logger = Logger(
        subsystem: "net.atompowered.retroview",
        category: "PreviewApplication"
    )
    
    static func openCard(_ card: CardSchemaV1.StereoCard) -> PreviewSession? {
        // If we have spatial photo data, write to temp file and open
        if let data = card.spatialPhotoData,
           let url = card.writeToTemporary(data: data)
        {
            logger.debug("Opening existing spatial photo for card \(card.uuid)")
            return open(urls: [url])
        }
        
        // Otherwise, queue up creation and preview
        Task {
            do {
                let imageLoader = CardImageLoader()
                
                guard let sourceImage = try await imageLoader.loadImage(
                    for: card,
                    side: .front,
                    quality: .high
                ) else {
                    logger.error("Failed to load source image")
                    return
                }
                
                let manager = SpatialPhotoManager(modelContext: card.modelContext!)
                try await manager.createSpatialPhoto(from: card, sourceImage: sourceImage)
                
                if let data = card.spatialPhotoData,
                   let url = card.writeToTemporary(data: data)
                {
                    await MainActor.run {
                        _ = open(urls: [url])
                    }
                }
            } catch {
                logger.error("Failed to create spatial photo: \(error.localizedDescription)")
            }
        }
        
        return nil
    }
    
    static func openCards(_ cards: [CardSchemaV1.StereoCard], selectedCard: CardSchemaV1.StereoCard? = nil) -> PreviewSession? {
        // Get URLs for cards that have spatial photos
        let urls = cards.compactMap { card -> URL? in
            guard let data = card.spatialPhotoData else { return nil }
            return card.writeToTemporary(data: data)
        }
        
        if !urls.isEmpty {
            let selectedURL = selectedCard.flatMap { card -> URL? in
                guard let data = card.spatialPhotoData else { return nil }
                return card.writeToTemporary(data: data)
            }
            return open(urls: urls, selectedURL: selectedURL)
        }
        
        // Otherwise start with first card
        if let firstCard = cards.first {
            return openCard(firstCard)
        }
        
        return nil
    }
}

// Helper extension for temporary file management
extension CardSchemaV1.StereoCard {
    func writeToTemporary(data: Data) -> URL? {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(uuid.uuidString)
            .appendingPathExtension("heic")
        
        try? data.write(to: url)
        return url
    }
}

// Add a convenience computed property to the card model
extension CardSchemaV1.StereoCard {
    var displayTitle: String {
        titlePick?.text ?? "Untitled Card"
    }
}

// Add a convenience property to the card model
extension CardSchemaV1.StereoCard {
    var spatialPhotoURL: URL? {
        // Check in app's cache directory for existing conversion
        guard
            let cachesDirectory = FileManager.default.urls(
                for: .cachesDirectory, in: .userDomainMask
            ).first
        else {
            return nil
        }

        let spatialPhotosDir = cachesDirectory.appendingPathComponent(
            "SpatialPhotos")
        let spatialPhotoURL = spatialPhotosDir.appendingPathComponent(
            "\(uuid.uuidString).heic")

        // Ensure the directory exists
        try? FileManager.default.createDirectory(
            at: spatialPhotosDir,
            withIntermediateDirectories: true
        )

        return FileManager.default.fileExists(atPath: spatialPhotoURL.path)
            ? spatialPhotoURL : nil
    }
}

extension Logger {
    /// Log a debug message with file and line information
    func debugWithContext(
        _ message: String, file: String = #file, line: Int = #line
    ) {
        let filename = file.split(separator: "/").last ?? ""
        self.log(level: .debug, "\(message) [\(filename):\(line)]")
    }

    /// Log an error message with file and line information
    func errorWithContext(
        _ message: String, file: String = #file, line: Int = #line
    ) {
        let filename = file.split(separator: "/").last ?? ""
        self.log(level: .error, "\(message) [\(filename):\(line)]")
    }

    /// Log an info message with file and line information
    func infoWithContext(
        _ message: String, file: String = #file, line: Int = #line
    ) {
        let filename = file.split(separator: "/").last ?? ""
        self.log(level: .info, "\(message) [\(filename):\(line)]")
    }

    //    /// Log a warning message with file and line information
    //    func warningWithContext(_ message: String, file: String = #file, line: Int = #line) {
    //        let filename = file.split(separator: "/").last ?? ""
    //        self.log(level: .warning, "\(message) [\(filename):\(line)]")
    //    }
}
