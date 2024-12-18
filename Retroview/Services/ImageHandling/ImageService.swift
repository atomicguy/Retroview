//
//  ImageService.swift
//  Retroview
//
//  Created by Adam Schuster on 12/7/24.
//

// ImageService.swift

import CoreGraphics
import Foundation

// MARK: - Image Service Protocol
protocol ImageServiceProtocol: Sendable {
    func loadImage(id: String, side: CardSide, quality: ImageQuality)
        async throws -> CGImage
    func loadThumbnail(id: String, side: CardSide, maxSize: CGFloat)
        async throws -> CGImage
    func loadCrop(id: String, side: CardSide, cropParameters: CropParameters)
        async throws -> CGImage
    nonisolated func clearCache()
}

// MARK: - Image Service Configuration
struct ImageServiceConfiguration: Sendable {
    let baseURL: URL
    let cacheSizeLimit: Int
    let maxConcurrentOperations: Int
    let defaultThumbnailSize: CGFloat

    static let `default` = ImageServiceConfiguration(
        baseURL: URL(string: "https://iiif-prod.nypl.org/index.php")!,
        cacheSizeLimit: 500 * 1024 * 1024,
        maxConcurrentOperations: 4,
        defaultThumbnailSize: 800
    )
}

// MARK: - Image Cache
actor ImageCache {
    private var cache: [String: CachedImage] = [:]
    private let sizeLimit: Int
    private var currentSize: Int = 0

    init(sizeLimit: Int) {
        self.sizeLimit = sizeLimit
    }

    final class CachedImage {
        let image: CGImage
        let size: Int
        var lastAccessed: Date

        init(image: CGImage) {
            self.image = image
            self.size = image.bytesPerRow * image.height
            self.lastAccessed = Date()
        }

        func touch() {
            lastAccessed = Date()
        }
    }

    func insert(_ image: CGImage, forKey key: String) {
        let cached = CachedImage(image: image)

        // Ensure we have space
        while currentSize + cached.size > sizeLimit {
            evictLeastRecentlyUsed()
        }

        cache[key] = cached
        currentSize += cached.size
    }

    func get(_ key: String) -> CGImage? {
        guard let cached = cache[key] else { return nil }
        cached.touch()  // Update access time
        return cached.image
    }

    private func evictLeastRecentlyUsed() {
        guard
            let oldest = cache.min(by: {
                $0.value.lastAccessed < $1.value.lastAccessed
            })
        else {
            return
        }
        cache.removeValue(forKey: oldest.key)
        currentSize -= oldest.value.size
    }

    func clear() {
        cache.removeAll()
        currentSize = 0
    }

    // Fixed the integer calculation
    func trim() {
        let trimLimit = (sizeLimit * 8) / 10  // 80% of size limit
        while currentSize > trimLimit {
            evictLeastRecentlyUsed()
        }
    }
}

// MARK: - Main Image Service Implementation
actor ImageService: ImageServiceProtocol {
    nonisolated let configuration: ImageServiceConfiguration
    private let cache: ImageCache
    private let imageLoader: ImageLoading
    
    init(
        configuration: ImageServiceConfiguration = .default,
        imageLoader: ImageLoading = DefaultImageLoader()
    ) {
        self.configuration = configuration
        self.cache = ImageCache(sizeLimit: configuration.cacheSizeLimit)
        self.imageLoader = imageLoader
    }
    
    nonisolated func clearCache() {
        Task { await cache.clear() }
    }

    func loadImage(
        id: String,
        side: CardSide,
        quality: ImageQuality = .standard
    ) async throws -> CGImage {
        let key = "\(id)_\(side.rawValue)_\(quality.rawValue)"
        
        // Check cache first
        if let cached = await cache.get(key) {
            return cached
        }
        
        // Create URL
        var components = URLComponents(url: configuration.baseURL, resolvingAgainstBaseURL: true)
        components?.queryItems = [
            URLQueryItem(name: "id", value: id),
            URLQueryItem(name: "t", value: quality.rawValue)
        ]
        
        guard let url = components?.url else {
            throw ImageServiceError.invalidURL
        }
        
        // Download data
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ImageServiceError.downloadFailed
        }
        
        // Process image
        guard let processedImage = await imageLoader.createCGImage(from: data) else {
            throw ImageServiceError.processingFailed
        }
        
        // Cache result
        await cache.insert(processedImage, forKey: key)
        
        return processedImage
    }
    
    func loadThumbnail(
        id: String,
        side: CardSide,
        maxSize: CGFloat
    ) async throws -> CGImage {
        return try await loadImage(id: id, side: side, quality: .thumbnail)
    }
    
    func loadCrop(
        id: String,
        side: CardSide,
        cropParameters: CropParameters
    ) async throws -> CGImage {
        let image = try await loadImage(id: id, side: side, quality: .standard)
        
        let key = "\(id)_\(side.rawValue)_crop_\(cropParameters.x0)_\(cropParameters.y0)_\(cropParameters.x1)_\(cropParameters.y1)"
        
        if let cached = await cache.get(key) {
            return cached
        }
        
        // Calculate dimensions
        let cropWidth = Int(CGFloat(image.width) * CGFloat(cropParameters.y1 - cropParameters.y0))
        let cropHeight = Int(CGFloat(image.height) * CGFloat(cropParameters.x1 - cropParameters.x0))
        
        // Create context for cropping
        guard let context = CGContext(
            data: nil,
            width: cropWidth,
            height: cropHeight,
            bitsPerComponent: image.bitsPerComponent,
            bytesPerRow: 0,
            space: image.colorSpace ?? CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: image.bitmapInfo.rawValue
        ) else {
            throw ImageServiceError.processingFailed
        }
        
        // Calculate offsets and draw
        let xOffset = -CGFloat(image.width) * CGFloat(cropParameters.y0)
        let yOffset = -CGFloat(image.height) * CGFloat(cropParameters.x0)
        
        context.translateBy(x: xOffset, y: yOffset)
        context.draw(
            image,
            in: CGRect(x: 0, y: 0, width: image.width, height: image.height)
        )
        
        guard let croppedImage = context.makeImage() else {
            throw ImageServiceError.processingFailed
        }
        
        // Cache cropped image
        await cache.insert(croppedImage, forKey: key)
        
        return croppedImage
    }
}

// MARK: - Image Service Errors
enum ImageServiceError: Error {
    case invalidURL
    case downloadFailed
    case processingFailed
}
