//
//  ImageLoader.swift
//  Retroview
//
//  Created by Adam Schuster on 11/20/24.
//

import CoreGraphics
import Foundation

actor ImageLoader {
    private let cache = NSCache<NSString, CGImage>()

    func loadImage(forCard card: CardSchemaV1.StereoCard, side: ImageSide)
        async throws -> CGImage
    {
        // Create a composite key from UUID and side
        let cacheKey = "\(card.uuid)-\(side.rawValue)" as NSString

        // Check cache first
        if let cached = cache.object(forKey: cacheKey) {
            return cached
        }

        // Get image data
        let imageData = side == .front ? card.imageFront : card.imageBack

        guard let data = imageData else {
            // If no data, try downloading
            try await card.downloadImage(forSide: side.rawValue)
            // Retry with downloaded data
            return try await loadImage(forCard: card, side: side)
        }

        // Create image
        guard let image = await createImage(from: data) else {
            throw ImageError.conversionFailed
        }

        // Cache the result
        cache.setObject(image, forKey: cacheKey)
        return image
    }

    private func createImage(from data: Data) async -> CGImage? {
        let loader = DefaultImageLoader()
        if let image = await loader.createCGImage(from: data) {
            return image
        }
        return await loader.createCGImageAlternative(from: data)
    }
}
