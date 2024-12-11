//
//  ImageService.swift
//  Retroview
//
//  Created by Adam Schuster on 12/7/24.
//

import Foundation
import CoreGraphics

import Foundation
import CoreGraphics

@Observable @MainActor
final class ImageService {
    private static let instance = ImageService(
        cache: ImageCache(sizeLimit: 500 * 1024 * 1024),
        loader: DefaultImageLoader()
    )
    
    static func getShared() async -> ImageService {
        await MainActor.run { instance }
    }
    
    private let cache: ImageCache
    private let loader: ImageLoading
    private let processingQueue: OperationQueue
    
    init(
        cache: ImageCache = ImageCache(sizeLimit: 500 * 1024 * 1024),
        loader: ImageLoading = DefaultImageLoader()
    ) {
        self.cache = cache
        self.loader = loader
        self.processingQueue = OperationQueue()
        self.processingQueue.maxConcurrentOperationCount = 4
    }
    
    // MARK: - Public Methods
    func loadImage(id: String, side: CardSide) async throws -> CGImage {
        guard !id.isEmpty else {
            throw AppError.invalidData("Image ID cannot be empty")
        }
        
        let cacheKey = "\(id)_\(side.rawValue)"
        
        if let cached = await cache.get(cacheKey) {
            return cached
        }
        
        do {
            let imageData = try await downloadImage(id: id)
            
            guard let image = await loader.createCGImage(from: imageData) else {
                throw AppError.imageProcessingFailed
            }
            
            await cache.insert(image, forKey: cacheKey)
            return image
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.imageLoadFailed(id)
        }
    }
    
    func clearCache() {
        Task {
            await cache.clear()
        }
    }
    
    // MARK: - Private Methods
    private func downloadImage(id: String) async throws -> Data {
        let baseURL = "https://iiif-prod.nypl.org/index.php"
        guard var components = URLComponents(string: baseURL) else {
            throw AppError.invalidURL
        }
        
        components.queryItems = [
            URLQueryItem(name: "id", value: id),
            URLQueryItem(name: "t", value: "w")
        ]
        
        guard let url = components.url else {
            throw AppError.invalidURL
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AppError.responseError("Invalid response type")
            }
            
            guard (200...299).contains(httpResponse.statusCode) else {
                throw AppError.serverError(httpResponse.statusCode)
            }
            
            return data
        } catch let error as AppError {
            throw error
        } catch {
            throw AppError.networkError(error)
        }
    }
}

// MARK: - Image Service Errors
enum ImageServiceError: Error {
    case invalidURL
    case downloadFailed
    case processingFailed
}
