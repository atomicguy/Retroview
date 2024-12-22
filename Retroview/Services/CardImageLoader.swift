//
//  CardImageLoader.swift
//  Retroview
//
//  Created by Adam Schuster on 12/22/24.
//

import SwiftUI
import SwiftData

@Observable
class CardImageLoader {
    private var cache = NSCache<NSString, CGImage>()
    
    func loadImage(for card: CardSchemaV1.StereoCard, side: CardSide, quality: ImageQuality) async throws -> CGImage? {
        let cacheKey = NSString(string: "\(card.uuid)-\(side.rawValue)-\(quality.rawValue)")
        
        // Check cache
        if let cachedImage = cache.object(forKey: cacheKey) {
            return cachedImage
        }
        
        // Create image manager
        let imageManager = CardImageManager(card: card, side: side, quality: quality)
        guard let url = imageManager.imageURL else { return nil }
        
        // Load image
        let (data, _) = try await URLSession.shared.data(from: url)
        
        guard let provider = CGDataProvider(data: data as CFData),
              let image = CGImage(
                jpegDataProviderSource: provider,
                decode: nil,
                shouldInterpolate: true,
                intent: .defaultIntent)
        else {
            return nil
        }
        
        // Cache the image
        cache.setObject(image, forKey: cacheKey)
        return image
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
}
