//
//  PreviewApplication+Cards.swift
//  Retroview
//
//  Created by Adam Schuster on 12/29/24.
//

import OSLog
import SwiftUI
import QuickLook

extension PreviewApplication {
    private static let logger = Logger(
        subsystem: "net.atompowered.retroview", category: "PreviewApplication"
    )

    static func openCards(
        _ cards: [CardSchemaV1.StereoCard],
        selectedCard: CardSchemaV1.StereoCard? = nil
    ) -> PreviewSession? {
        // Convert cards to preview items
        let items = cards.compactMap { card -> PreviewItem? in
            guard let data = card.spatialPhotoData,
                  let url = card.writeToTemporary(data: data) else { return nil }
            return card.asPreviewItem(url: url)
        }
        
        if !items.isEmpty {
            // If we have items, open them all in one preview session
            return open(items: items)
        }
        
        // If no existing items, start conversion for first card
        if let firstCard = cards.first {
            convertAndOpenCard(firstCard)
        }
        
        return nil
    }
    
    private static func convertAndOpenCard(_ card: CardSchemaV1.StereoCard) -> PreviewSession? {
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
                   let url = card.writeToTemporary(data: data) {
                    await MainActor.run {
                        _ = open(items: [card.asPreviewItem(url: url)])
                    }
                }
            } catch {
                logger.error("Failed to create spatial photo: \(error.localizedDescription)")
            }
        }
        return nil
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
