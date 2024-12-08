//
//  ImageService.swift
//  Retroview
//
//  Created by Adam Schuster on 12/7/24.
//

// ImageService.swift

import Foundation
import CoreGraphics

// MARK: - Image Service Protocol
protocol ImageServiceProtocol {
    func loadImage(id: String, side: CardSide) async throws -> CGImage
    func loadThumbnail(id: String, side: CardSide, maxSize: CGFloat) async throws -> CGImage
    func loadCrop(id: String, side: CardSide, crop: CropSchemaV1.Crop) async throws -> CGImage
    func clearCache()
}

// MARK: - Image Service Configuration
struct ImageServiceConfiguration {
    let baseURL: URL
    let cacheSizeLimit: Int // in bytes
    let maxConcurrentOperations: Int
    let defaultThumbnailSize: CGFloat
    
    static let `default` = ImageServiceConfiguration(
        baseURL: URL(string: "https://iiif-prod.nypl.org/index.php")!,
        cacheSizeLimit: 500 * 1024 * 1024, // 500MB
        maxConcurrentOperations: 4,
        defaultThumbnailSize: 800
    )
}

// MARK: - Card Side Enum
enum CardSide: String {
    case front, back
    
    var suffix: String {
        switch self {
        case .front: return "F"
        case .back: return "B"
        }
    }
}

// MARK: - Image Cache
actor ImageCache {
    private var cache: [String: CachedImage] = [:]
    private let sizeLimit: Int
    private var currentSize: Int = 0
    
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
        
        // Ensure we have space
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
        // Update last accessed time
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

// MARK: - Main Image Service Implementation
final class ImageService: ImageServiceProtocol {
    private let configuration: ImageServiceConfiguration
    private let cache: ImageCache
    private let imageLoader: ImageLoading
    private let processingQueue: OperationQueue
    
    init(
        configuration: ImageServiceConfiguration = .default,
        imageLoader: ImageLoading = DefaultImageLoader()
    ) {
        self.configuration = configuration
        self.cache = ImageCache(sizeLimit: configuration.cacheSizeLimit)
        self.imageLoader = imageLoader
        
        self.processingQueue = OperationQueue()
        self.processingQueue.maxConcurrentOperationCount = configuration.maxConcurrentOperations
    }
    
    // MARK: - Public Methods
    
    func loadImage(id: String, side: CardSide) async throws -> CGImage {
        let cacheKey = "\(id)_\(side.rawValue)_full"
        
        // Check cache first
        if let cached = await cache.get(cacheKey) {
            return cached
        }
        
        // Load full resolution image
        let imageData = try await downloadImage(id: id, side: side)
        guard let image = await imageLoader.createCGImage(from: imageData) else {
            throw ImageServiceError.processingFailed
        }
        
        // Cache the result
        await cache.insert(image, forKey: cacheKey)
        return image
    }
    
    func loadThumbnail(id: String, side: CardSide, maxSize: CGFloat) async throws -> CGImage {
        let cacheKey = "\(id)_\(side.rawValue)_thumb_\(Int(maxSize))"
        
        // Check cache first
        if let cached = await cache.get(cacheKey) {
            return cached
        }
        
        // Get full image first
        let fullImage = try await loadImage(id: id, side: side)
        
        // Generate thumbnail
        let thumbnail = try await generateThumbnail(from: fullImage, maxSize: maxSize)
        
        // Cache the result
        await cache.insert(thumbnail, forKey: cacheKey)
        return thumbnail
    }
    
    func loadCrop(id: String, side: CardSide, crop: CropSchemaV1.Crop) async throws -> CGImage {
        let cacheKey = "\(id)_\(side.rawValue)_crop_\(crop.description)"
        
        // Check cache first
        if let cached = await cache.get(cacheKey) {
            return cached
        }
        
        // Get full image first
        let fullImage = try await loadImage(id: id, side: side)
        
        // Generate crop
        let croppedImage = try await generateCrop(from: fullImage, crop: crop)
        
        // Cache the result
        await cache.insert(croppedImage, forKey: cacheKey)
        return croppedImage
    }
    
    func clearCache() {
        Task {
            await cache.clear()
        }
    }
    
    // MARK: - Private Methods
    
    private func downloadImage(id: String, side: CardSide) async throws -> Data {
        var components = URLComponents(url: configuration.baseURL, resolvingAgainstBaseURL: true)!
        components.queryItems = [
            URLQueryItem(name: "id", value: id),
            URLQueryItem(name: "t", value: "w")
        ]
        
        guard let url = components.url else {
            throw ImageServiceError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw ImageServiceError.downloadFailed
        }
        
        return data
    }
    
    private func generateThumbnail(from image: CGImage, maxSize: CGFloat) async throws -> CGImage {
        try await withCheckedThrowingContinuation { continuation in
            processingQueue.addOperation {
                let originalSize = CGSize(width: image.width, height: image.height)
                let scale = maxSize / max(originalSize.width, originalSize.height)
                let newSize = CGSize(
                    width: originalSize.width * scale,
                    height: originalSize.height * scale
                )
                
                let context = CGContext(
                    data: nil,
                    width: Int(newSize.width),
                    height: Int(newSize.height),
                    bitsPerComponent: image.bitsPerComponent,
                    bytesPerRow: 0,
                    space: image.colorSpace ?? CGColorSpaceCreateDeviceRGB(),
                    bitmapInfo: image.bitmapInfo.rawValue
                )
                
                context?.interpolationQuality = .high
                context?.draw(
                    image,
                    in: CGRect(origin: .zero, size: newSize)
                )
                
                if let thumbnail = context?.makeImage() {
                    continuation.resume(returning: thumbnail)
                } else {
                    continuation.resume(throwing: ImageServiceError.processingFailed)
                }
            }
        }
    }
    
    private func generateCrop(from image: CGImage, crop: CropSchemaV1.Crop) async throws -> CGImage {
        try await withCheckedThrowingContinuation { continuation in
            processingQueue.addOperation {
                let cropWidth = Int(
                    CGFloat(crop.y1 - crop.y0) * CGFloat(image.width)
                )
                let cropHeight = Int(
                    CGFloat(crop.x1 - crop.x0) * CGFloat(image.height)
                )
                
                let context = CGContext(
                    data: nil,
                    width: cropWidth,
                    height: cropHeight,
                    bitsPerComponent: image.bitsPerComponent,
                    bytesPerRow: 0,
                    space: image.colorSpace ?? CGColorSpaceCreateDeviceRGB(),
                    bitmapInfo: image.bitmapInfo.rawValue
                )
                
                let xOffset = -CGFloat(crop.y0) * CGFloat(image.width)
                let yOffset = -CGFloat(crop.x0) * CGFloat(image.height)
                
                context?.translateBy(x: xOffset, y: yOffset)
                context?.clip(
                    to: CGRect(
                        x: Int(-xOffset),
                        y: Int(-yOffset),
                        width: cropWidth,
                        height: cropHeight
                    )
                )
                
                context?.draw(
                    image,
                    in: CGRect(
                        x: 0,
                        y: 0,
                        width: image.width,
                        height: image.height
                    )
                )
                
                if let croppedImage = context?.makeImage() {
                    continuation.resume(returning: croppedImage)
                } else {
                    continuation.resume(throwing: ImageServiceError.processingFailed)
                }
            }
        }
    }
}

// MARK: - Image Service Errors
enum ImageServiceError: Error {
    case invalidURL
    case downloadFailed
    case processingFailed
}
