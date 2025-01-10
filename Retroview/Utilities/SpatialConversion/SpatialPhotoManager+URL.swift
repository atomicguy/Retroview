//
//  SpatialPhotoManager+URL.swift
//  Retroview
//
//  Created by Adam Schuster on 1/9/25.
//

import Foundation

extension SpatialPhotoManager {
    func getOrCreateSharingURL(for card: CardSchemaV1.StereoCard, imageLoader: CardImageLoader) async throws -> URL {
        // Return existing URL if spatial photo already exists
        if let existingURL = card.createSharingURL() {
            return existingURL
        }
        
        // Load high quality image
        guard let sourceImage = try await imageLoader.loadImage(
            for: card,
            side: .front,
            quality: .ultra
        ) else {
            throw StereoError.imageLoadFailed
        }
        
        // Create spatial photo - ignore returned data since it's stored in SwiftData
        _ = try await getSpatialPhotoData(
            for: card,
            sourceImage: sourceImage
        )
        
        // Now that spatial data exists, create and return URL
        guard let url = card.createSharingURL() else {
            throw StereoError.missingRequiredData
        }
        return url
    }
}
