//
//  StoreCleanupService.swift
//  Retroview
//
//  Created by Adam Schuster on 12/7/24.
//

import Foundation
import SwiftData

@MainActor
final class StoreCleanupService {
    static let shared = StoreCleanupService()
    private let fileManager = FileManager.default
    
    private init() {}
    
    func cleanupStore() async throws {
        // Get all potential store URLs
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let previewDir = appSupport.appendingPathComponent("PreviewData", isDirectory: true)
        
        let storeLocations = [
            appSupport.appendingPathComponent("MyStereoviews.store"),
            appSupport.appendingPathComponent("default.store"),
            previewDir.appendingPathComponent("preview.store")
        ]
        
        // Delete all store files and their auxiliary files
        for storeURL in storeLocations {
            let baseURL = storeURL.deletingPathExtension()
            let basePath = baseURL.path
            
            // Wait a moment to ensure connections are closed
            try await Task.sleep(for: .milliseconds(100))
            
            try? fileManager.removeItem(atPath: "\(basePath).store")
            try? fileManager.removeItem(atPath: "\(basePath).store-shm")
            try? fileManager.removeItem(atPath: "\(basePath).store-wal")
        }
        
        // Reset development flags after cleanup
        DevelopmentFlags.reset()
        
        // Reset preview data manager
        try await PreviewDataManager.shared.reset()
    }
}
