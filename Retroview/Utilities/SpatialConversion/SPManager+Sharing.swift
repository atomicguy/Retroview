//
//  SPManager+Sharing.swift
//  Retroview
//
//  Created by Adam Schuster on 1/10/25.
//

import SwiftUI
import Foundation

@MainActor
extension SpatialPhotoManager {
    func prepareForSharing(card: CardSchemaV1.StereoCard, imageLoader: CardImageLoader) async throws -> URL {
        // First try to get existing spatial photo
        if let url = card.createSharingURL() {
            return url
        }

        // Load high quality image and create spatial photo
        guard let sourceImage = try await imageLoader.loadImage(
            for: card,
            side: .front,
            quality: .ultra
        ) else {
            throw StereoError.missingDependencies
        }

        // Create spatial photo
        _ = try await getSpatialPhotoData(for: card, sourceImage: sourceImage)
        
        // Now that spatial data exists, get sharing URL
        guard let url = card.createSharingURL() else {
            throw StereoError.missingRequiredData
        }
        
        return url
    }
}
