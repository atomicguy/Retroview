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
protocol ImageServiceProtocol {
    func loadImage(id: String, side: CardSide, quality: ImageQuality)
        async throws -> CGImage
    func loadThumbnail(id: String, side: CardSide, maxSize: CGFloat)
        async throws -> CGImage
    func loadCrop(id: String, side: CardSide, cropParameters: CropParameters)
        async throws -> CGImage
    func clearCache()
}

// MARK: - Image Service Configuration
struct ImageServiceConfiguration {
    let baseURL: URL
    let cacheSizeLimit: Int  // in bytes
    let maxConcurrentOperations: Int
    let defaultThumbnailSize: CGFloat

    static let `default` = ImageServiceConfiguration(
        baseURL: URL(string: "https://iiif-prod.nypl.org/index.php")!,
        cacheSizeLimit: 500 * 1024 * 1024,  // 500MB
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
class ImageService: ImageServiceProtocol {
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
        self.processingQueue.maxConcurrentOperationCount =
            configuration.maxConcurrentOperations
    }

    // Create cache keys based on image quality and ID
    private func cacheKey(id: String, side: CardSide, quality: ImageQuality)
        -> String
    {
        "\(id)_\(side.rawValue)_\(quality.rawValue)"
    }

    func loadImage(
        id: String, side: CardSide, quality: ImageQuality = .standard
    ) async throws -> CGImage {
        let key = cacheKey(id: id, side: side, quality: quality)

        // Check cache first
        if let cached = await cache.get(key) {
            return cached
        }

        // Download and process image
        let imageData = try await downloadImage(id: id, quality: quality)
        guard let image = await imageLoader.createCGImage(from: imageData)
        else {
            throw ImageServiceError.processingFailed
        }

        // Cache the result
        await cache.insert(image, forKey: key)

        // Trim cache if needed
        await cache.trim()

        return image
    }

    func loadThumbnail(id: String, side: CardSide, maxSize: CGFloat)
        async throws -> CGImage
    {
        // Always use thumbnail quality for grid
        return try await loadImage(id: id, side: side, quality: .thumbnail)
    }

    func loadCrop(id: String, side: CardSide, cropParameters: CropParameters)
        async throws -> CGImage
    {
        let image = try await loadImage(id: id, side: side, quality: .standard)
        let cacheKey = "\(id)_\(side.rawValue)_crop_\(cropParameters)"

        // Process the crop
        let croppedImage = try await withCheckedThrowingContinuation {
            continuation in
            processingQueue.addOperation {
                let cropWidth = Int(
                    CGFloat(cropParameters.y1 - cropParameters.y0)
                        * CGFloat(image.width)
                )
                let cropHeight = Int(
                    CGFloat(cropParameters.x1 - cropParameters.x0)
                        * CGFloat(image.height)
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

                let xOffset = -CGFloat(cropParameters.y0) * CGFloat(image.width)
                let yOffset =
                    -CGFloat(cropParameters.x0) * CGFloat(image.height)

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
                    continuation.resume(
                        throwing: ImageServiceError.processingFailed)
                }
            }
        }

        await cache.insert(croppedImage, forKey: cacheKey)
        return croppedImage
    }

    private func downloadImage(id: String, quality: ImageQuality) async throws
        -> Data
    {
        var components = URLComponents(
            url: configuration.baseURL, resolvingAgainstBaseURL: true)!
        components.queryItems = [
            URLQueryItem(name: "id", value: id),
            URLQueryItem(name: "t", value: quality.rawValue),
        ]

        guard let url = components.url else {
            throw ImageServiceError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
            httpResponse.statusCode == 200
        else {
            throw ImageServiceError.downloadFailed
        }

        return data
    }

    func clearCache() {
        Task {
            await cache.clear()
        }
    }
}

// MARK: - Image Service Errors
enum ImageServiceError: Error {
    case invalidURL
    case downloadFailed
    case processingFailed
}
