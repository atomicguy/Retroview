//
//  PreviewDataManager.swift
//  Retroview
//
//  Created by Adam Schuster on 12/7/24.
//

import SwiftData
import SwiftUI

@MainActor
final class PreviewDataManager {
    static let shared = PreviewDataManager()
    
    private let previewStoreURL: URL
    private var modelContainer: ModelContainer?
    
    private init() {
        let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory, in: .userDomainMask
        ).first!
        let previewDir = appSupport.appendingPathComponent(
            "PreviewData", isDirectory: true)
        previewStoreURL = previewDir.appendingPathComponent("preview.store")
    }
    
    func container() throws -> ModelContainer {
        if let existing = modelContainer {
            return existing
        }
        
        let schema = Schema([
            CardSchemaV1.StereoCard.self,
            TitleSchemaV1.Title.self,
            AuthorSchemaV1.Author.self,
            SubjectSchemaV1.Subject.self,
            DateSchemaV1.Date.self,
            CropSchemaV1.Crop.self,
            CollectionSchemaV1.Collection.self,
        ])
        
        // Always create a fresh configuration
        let config = ModelConfiguration(
            schema: schema,
            url: previewStoreURL,
            allowsSave: true
        )
        
        let container = try ModelContainer(
            for: schema,
            configurations: [config]
        )
        modelContainer = container
        return container
    }
    
    func reset() async throws {
        // Close existing container
        modelContainer = nil
        
        // Wait for any pending operations to complete
        try await Task.sleep(for: .milliseconds(100))
        
        // Delete store files
        let storeURLs = [
            previewStoreURL,
            previewStoreURL.appendingPathExtension("shm"),
            previewStoreURL.appendingPathExtension("wal")
        ]
        
        for url in storeURLs {
            try? FileManager.default.removeItem(at: url)
        }
        
        // Create fresh directory structure
        try? FileManager.default.createDirectory(
            at: previewStoreURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
    }
    
    func populatePreviewData() async throws {
        // Always reset before populating
        try await reset()
        
        print("Creating new preview container...")
        let container = try container()
        let context = container.mainContext
        
        print("Starting preview data population...")
        
        // Create base entities
        let titles = createTitles(context: context)
        let authors = createAuthors(context: context)
        let subjects = createSubjects(context: context)
        let dates = createDates(context: context)
        
        // Create sample cards with relationships
        try await createSampleCards(
            context: context,
            titles: titles,
            authors: authors,
            subjects: subjects,
            dates: dates
        )
        
        // Create collections
        createCollections(context: context)
        
        try context.save()
        print("Preview data population complete")
    }
}
