//
//  StoreUtility.swift
//  Retroview
//
//  Created by Adam Schuster on 12/15/24.
//

import Foundation
import SwiftData

#if DEBUG
struct StoreUtility {
    static func resetStore() {
        let fileManager = FileManager.default
        guard let appSupport = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else { return }
        
        // List of store files to remove
        let storeFiles = [
            "MyStereoviews.store",
            "MyStereoviews.store-shm",
            "MyStereoviews.store-wal",
            "default.store",
            "default.store-shm",
            "default.store-wal"
        ]
        
        // Remove each store file
        for file in storeFiles {
            let url = appSupport.appendingPathComponent(file)
            try? fileManager.removeItem(at: url)
        }
        
        // Clean up preview data if it exists
        let previewURL = appSupport.appendingPathComponent("PreviewData")
        try? fileManager.removeItem(at: previewURL)
    }
}
#endif
