//
//  StoreManager.swift
//  Retroview
//
//  Created by Adam Schuster on 12/7/24.
//

import Foundation
import SwiftData

final class StoreManager {
    static let shared = StoreManager()
    private let fileManager = FileManager.default
    
    private init() {}
    
    func resetStore() throws {
        let appSupportURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        
        // List of store files to delete
        let storeFiles = [
            "MyStereoviews.store",
            "MyStereoviews.store-shm",
            "MyStereoviews.store-wal",
            "default.store",
            "default.store-shm",
            "default.store-wal"
        ]
        
        // Delete each store file if it exists
        for fileName in storeFiles {
            let fileURL = appSupportURL.appendingPathComponent(fileName)
            if fileManager.fileExists(atPath: fileURL.path) {
                do {
                    try fileManager.removeItem(at: fileURL)
                    print("Successfully deleted: \(fileName)")
                } catch {
                    print("Failed to delete \(fileName): \(error)")
                }
            }
        }
        
        // Reset development flags
        DevelopmentFlags.reset()
    }
}
