//
//  ImageCache.swift
//  Retroview
//
//  Created by Adam Schuster on 12/9/24.
//

import CoreGraphics
import Foundation

actor ImageCache {
    private var cache: [String: CachedImage] = [:]
    private let sizeLimit: Int
    private var currentSize = 0
    
    struct CachedImage {
        let image: CGImage
        let size: Int
        let lastAccessed: Date
    }
    
    init(sizeLimit: Int) {
        self.sizeLimit = sizeLimit
    }
    
    func insert(_ image: CGImage, forKey key: String) {
        let imageSize = image.bytesPerRow * image.height
        
        while currentSize + imageSize > sizeLimit {
            evictLeastRecentlyUsed()
        }
        
        cache[key] = CachedImage(
            image: image,
            size: imageSize,
            lastAccessed: Date()
        )
        currentSize += imageSize
    }
    
    func get(_ key: String) -> CGImage? {
        guard let cached = cache[key] else { return nil }
        cache[key] = CachedImage(
            image: cached.image,
            size: cached.size,
            lastAccessed: Date()
        )
        return cached.image
    }
    
    private func evictLeastRecentlyUsed() {
        guard let oldest = cache.min(by: { $0.value.lastAccessed < $1.value.lastAccessed }) else {
            return
        }
        cache.removeValue(forKey: oldest.key)
        currentSize -= oldest.value.size
    }
    
    func clear() {
        cache.removeAll()
        currentSize = 0
    }
}
