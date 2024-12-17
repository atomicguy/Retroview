//
//  ImageService+Quality.swift
//  Retroview
//
//  Created by Adam Schuster on 12/16/24.
//

import Foundation
import CoreGraphics

extension CardSchemaV1.StereoCard {
    func loadImage(side: CardSide, quality: ImageQuality = .standard) async throws -> CGImage? {
        // Verify we have an image ID
        let imageId = side == .front ? imageFrontId : imageBackId
        guard let imageId = imageId else { return nil }
        
        let service = ImageServiceFactory.shared.getService()
        
        // Load the image with specified quality
        let image = try await service.loadImage(
            id: imageId,
            side: side,
            quality: quality
        )
        
        // Store in ImageStore for persistence if it's a standard quality image
        if quality == .standard {
            let store = await getOrCreateImageStore(side: side)
            if let store = store,
               let imageData = ImageConversion.convert(cgImage: image) {
                store.setImage(imageData)
            }
        }
        
        return image
    }
    
    // Specialized method for grid thumbnails
    func loadGridThumbnail() async throws -> CGImage? {
        guard let frontId = imageFrontId else { return nil }
        
        let service = ImageServiceFactory.shared.getService()
        return try await service.loadThumbnail(
            id: frontId,
            side: .front,
            maxSize: 140  // Thumbnail size
        )
    }
}
