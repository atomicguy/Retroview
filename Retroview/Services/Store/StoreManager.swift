//
//  StoreManager.swift
//  Retroview
//
//  Created by Adam Schuster on 12/9/24.
//

import Foundation
import SwiftData

final class StoreManager {
    static let shared = StoreManager()
    
    private init() {}
    
    @MainActor func resetStore() throws {
        let fileManager = FileManager.default
        guard let appSupport = fileManager.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first else { return }
        
        let storeURLs = [
            appSupport.appendingPathComponent("Retroview.store"),
            appSupport.appendingPathComponent("Retroview.store-shm"),
            appSupport.appendingPathComponent("Retroview.store-wal")
        ]
        
        for url in storeURLs {
            try? fileManager.removeItem(at: url)
        }
        
        ImageService.shared().clearCache()
    }
    
    func createContainer() throws -> ModelContainer {
        let schema = Schema([
            CardSchemaV1.StereoCard.self,
            TitleSchemaV1.Title.self,
            AuthorSchemaV1.Author.self,
            SubjectSchemaV1.Subject.self,
            DateSchemaV1.Date.self,
            CropSchemaV1.Crop.self,
            CollectionSchemaV1.Collection.self,
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        
        return try ModelContainer(
            for: schema,
            configurations: [modelConfiguration]
        )
    }
}

