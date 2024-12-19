//
//  ImageCacheService.swift
//  Retroview
//
//  Created by Adam Schuster on 12/16/24.
//

import Combine
import CoreGraphics
import SwiftUI

@Observable
final class ImageCacheService: @unchecked Sendable {
    static let shared = ImageCacheService()
    
    private let cache = NSCache<NSString, CGImage>()
    private let downloadQueue = OperationQueue()
    
    private init() {
        cache.countLimit = 200
        downloadQueue.maxConcurrentOperationCount = 4
    }
    
    func image(for id: String) -> CGImage? {
        cache.object(forKey: id as NSString)
    }
    
    func cache(_ image: CGImage, for id: String) {
        cache.setObject(image, forKey: id as NSString)
    }
    
    func clear() {
        cache.removeAllObjects()
    }
    
    // Take just the IDs instead of the whole cards
    func prefetch(imageIds: [String]) {
        Task {
            for imageId in imageIds {
                // Skip if already cached
                if cache.object(forKey: imageId as NSString) != nil {
                    continue
                }
                
                // Queue thumbnail download
                downloadQueue.addOperation {
                    Task {
                        do {
                            let urlString = "https://iiif-prod.nypl.org/index.php?id=\(imageId)&t=\(ImageQuality.thumbnail.rawValue)"
                            guard let url = URL(string: urlString) else { return }
                            
                            let (data, _) = try await URLSession.shared.data(from: url)
                            
                            guard let provider = CGDataProvider(data: data as CFData),
                                  let image = CGImage(
                                    jpegDataProviderSource: provider,
                                    decode: nil,
                                    shouldInterpolate: true,
                                    intent: .defaultIntent
                                  )
                            else {
                                return
                            }
                            
                            self.cache(image, for: imageId)
                        } catch {
                            print("Prefetch failed for \(imageId): \(error)")
                        }
                    }
                }
            }
        }
    }
}
// Environment key for dependency injection
private struct ImageCacheKey: EnvironmentKey {
    static let defaultValue: ImageCacheService = .shared
}

extension EnvironmentValues {
    var imageCache: ImageCacheService {
        get { self[ImageCacheKey.self] }
        set { self[ImageCacheKey.self] = newValue }
    }
}
