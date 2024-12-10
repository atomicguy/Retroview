//
//  ImageService.swift
//  Retroview
//
//  Created by Adam Schuster on 12/7/24.
//

import Foundation
import CoreGraphics

@Observable @MainActor
final class ImageService {
    // MARK: - Singleton Access
    private static let _shared: ImageService = {
        let cache = ImageCache(sizeLimit: 500 * 1024 * 1024)
        let loader = DefaultImageLoader()
        return ImageService(cache: cache, loader: loader)
    }()
    
    static func shared() -> ImageService {
        return _shared
    }
    
    // MARK: - Properties
    private let cache: ImageCache
    private let loader: ImageLoading
    private let processingQueue: OperationQueue
    
    // MARK: - Initialization
    init(
        cache: ImageCache,
        loader: ImageLoading
    ) {
        self.cache = cache
        self.loader = loader
        self.processingQueue = OperationQueue()
        self.processingQueue.maxConcurrentOperationCount = 4
    }
    
    // MARK: - Public Methods
    func loadImage(id: String, side: CardSide) async throws -> CGImage {
        let cacheKey = "\(id)_\(side.rawValue)"
        
        if let cached = await cache.get(cacheKey) {
            return cached
        }
        
        let imageData = try await downloadImage(id: id)
        guard let image = await loader.createCGImage(from: imageData) else {
            throw ImageServiceError.processingFailed
        }
        
        await cache.insert(image, forKey: cacheKey)
        return image
    }
    
    func clearCache() {
        Task {
            await cache.clear()
        }
    }
    
    // MARK: - Private Methods
    private func downloadImage(id: String) async throws -> Data {
        let baseURL = "https://iiif-prod.nypl.org/index.php"
        var components = URLComponents(string: baseURL)!
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
}

// MARK: - Image Service Errors
enum ImageServiceError: Error {
    case invalidURL
    case downloadFailed
    case processingFailed
}
