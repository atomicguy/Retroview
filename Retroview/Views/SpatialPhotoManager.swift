//
//  SpatialPhotoManager.swift
//  Retroview
//
//  Created by Adam Schuster on 12/28/24.
//

import SwiftData
import SwiftUI
import OSLog

@Observable
final class SpatialPhotoManager {
    private let modelContext: ModelContext
    private let converter = StereoPhotoConverter()
    private let logger = Logger(subsystem: "net.atompowered.retroview", category: "SpatialPhotoManager")
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func createSpatialPhoto(from card: CardSchemaV1.StereoCard, sourceImage: CGImage) async throws {
        // Skip if we already have the data
        guard card.spatialPhotoData == nil else {
            logger.debug("Spatial photo already exists for card \(card.uuid)")
            return
        }
        
        logger.debug("Creating spatial photo for card \(card.uuid)")
        
        do {
            let url = try await converter.createTemporarySpatialPhoto(
                from: card,
                sourceImage: sourceImage
            )
            
            // Store in SwiftData
            card.spatialPhotoData = try Data(contentsOf: url)
            try modelContext.save()
            
            // Clean up temp file
            try? FileManager.default.removeItem(at: url)
            
            logger.debug("Successfully created and stored spatial photo")
        } catch {
            logger.error("Failed to create spatial photo: \(error.localizedDescription)")
            throw error
        }
    }
}
