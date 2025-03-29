//
//  ImageCache.swift
//  Retroview
//
//  Created by Adam Schuster on 3/24/25.
//

import Foundation
import OSLog

#if os(macOS)
import AppKit
#else
import UIKit
#endif

final class ImageCache {
    static let shared = ImageCache()
    private let memoryCache = NSCache<NSString, CGImage>()
    private let fileManager = FileManager.default
    private let diskCacheURL: URL
    private let logger = Logger(subsystem: "net.atompowered.retroview", category: "ImageCache")
    
    private init() {
        // Set up memory cache limits
        memoryCache.countLimit = 100 // Adjust based on your app's memory usage
        memoryCache.totalCostLimit = 50 * 1024 * 1024 // 50MB limit
        
        // Set up disk cache directory
        let cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        diskCacheURL = cacheDirectory.appendingPathComponent("ImageCache", isDirectory: true)
        
        try? fileManager.createDirectory(at: diskCacheURL, withIntermediateDirectories: true)
        
        // Platform-specific memory warning observation
        #if os(iOS) || os(visionOS)
        // iOS/visionOS memory warning notification
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(clearMemoryCache),
            name: UIApplication.didReceiveMemoryWarningNotification,
            object: nil
        )
        #elseif os(macOS)
        // On macOS, set up periodic cache cleaning
        setupPeriodicCacheCleaning()
        #endif
    }
    
    #if os(macOS)
    private func setupPeriodicCacheCleaning() {
        // On macOS, we'll clean the cache periodically
        DispatchQueue.global().asyncAfter(deadline: .now() + 300) { [weak self] in
            self?.performPeriodicCacheCleaning()
        }
    }
    
    private func performPeriodicCacheCleaning() {
        // Check current memory pressure
        let memoryStatus = ProcessInfo.processInfo.systemUptime
        
        // Just clean the cache periodically regardless
        DispatchQueue.main.async { [weak self] in
            self?.clearMemoryCache()
        }
        
        // Schedule next cleaning
        DispatchQueue.global().asyncAfter(deadline: .now() + 300) { [weak self] in
            self?.performPeriodicCacheCleaning()
        }
    }
    #endif
    
    @objc private func clearMemoryCache() {
        memoryCache.removeAllObjects()
        logger.debug("Memory cache cleared")
    }
    
    // Get image from cache (memory or disk)
    func getImage(forKey key: String) -> CGImage? {
        let cacheKey = NSString(string: key)
        
        // Check memory cache first
        if let cachedImage = memoryCache.object(forKey: cacheKey) {
            return cachedImage
        }
        
        // Check disk cache
        let fileURL = diskCacheURL.appendingPathComponent(key.replacingOccurrences(of: "/", with: "_"))
        guard fileManager.fileExists(atPath: fileURL.path) else {
            return nil
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            guard let provider = CGDataProvider(data: data as CFData),
                  let image = CGImage(jpegDataProviderSource: provider,
                                     decode: nil,
                                     shouldInterpolate: true,
                                     intent: .defaultIntent) else {
                return nil
            }
            
            // Store in memory cache
            memoryCache.setObject(image, forKey: cacheKey)
            return image
        } catch {
            logger.error("Failed to load image from disk cache: \(error.localizedDescription)")
            return nil
        }
    }
    
    // Store image in cache (memory and disk)
    func storeImage(_ image: CGImage, data: Data, forKey key: String) {
        let cacheKey = NSString(string: key)
        
        // Store in memory cache
        memoryCache.setObject(image, forKey: cacheKey)
        
        // Store in disk cache
        let fileURL = diskCacheURL.appendingPathComponent(key.replacingOccurrences(of: "/", with: "_"))
        do {
            try data.write(to: fileURL)
        } catch {
            logger.error("Failed to store image to disk cache: \(error.localizedDescription)")
        }
    }
    
    // Remove image from cache
    func removeImage(forKey key: String) {
        let cacheKey = NSString(string: key)
        
        // Remove from memory cache
        memoryCache.removeObject(forKey: cacheKey)
        
        // Remove from disk cache
        let fileURL = diskCacheURL.appendingPathComponent(key.replacingOccurrences(of: "/", with: "_"))
        try? fileManager.removeItem(at: fileURL)
    }
    
    // Clear entire cache
    func clearCache() {
        // Clear memory cache
        memoryCache.removeAllObjects()
        
        // Clear disk cache
        try? fileManager.removeItem(at: diskCacheURL)
        try? fileManager.createDirectory(at: diskCacheURL, withIntermediateDirectories: true)
    }
}
