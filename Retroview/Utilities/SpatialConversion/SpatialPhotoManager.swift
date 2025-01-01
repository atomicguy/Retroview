//
//  SpatialPhotoManager.swift
//  Retroview
//
//  Created by Adam Schuster on 12/28/24.
//

import OSLog
import SwiftData
import SwiftUI

@Observable
final class SpatialPhotoManager {
    private let modelContext: ModelContext
    private let converter: SpatialPhotoConverter
    private let logger = Logger(
        subsystem: "net.atompowered.retroview",
        category: "SpatialPhotoManager"
    )

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        self.converter = SpatialPhotoConverter()
    }

    func getSpatialPhotoData(
        for card: CardSchemaV1.StereoCard, sourceImage: CGImage
    ) async throws -> Data {
        if let existingData = card.spatialPhotoData {
            return existingData
        }

        let photoData = try await converter.createSpatialPhotoData(
            from: card,
            sourceImage: sourceImage
        )

        // Store in SwiftData
        card.spatialPhotoData = photoData
        try modelContext.save()

        return photoData
    }
}
