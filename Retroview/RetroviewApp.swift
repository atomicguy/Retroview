//
//  RetroviewApp.swift
//  Retroview
//
//  Created by Adam Schuster on 4/6/24.
//

import SwiftData
import SwiftUI

import SwiftData
import SwiftUI

@main
struct RetroviewApp: App {
    let sharedModelContainer: ModelContainer
    
    init() {
        #if DEBUG
        ImportLogger.configure(logLevel: .debug)
        #else
        ImportLogger.configure(logLevel: .error)
        #endif
        
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
            "MyStereoviews",
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )
        
        do {
            let container = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            
            #if DEBUG
            // Load demo data if needed
            Task { @MainActor in
                let context = container.mainContext
                let descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
                if let count = try? context.fetch(descriptor).count, count == 0 {
                    print("Loading demo data...")
                    try? await PreviewDataManager.shared.populatePreviewData()
                    print("Demo data loaded")
                }
            }
            #endif
            
            self.sharedModelContainer = container
        } catch {
            // If initial creation fails, try cleaning up and creating again
            print("Failed to create ModelContainer: \(error.localizedDescription)")
            StoreUtility.resetStore()
            
            do {
                self.sharedModelContainer = try ModelContainer(
                    for: schema,
                    configurations: [modelConfiguration]
                )
            } catch {
                fatalError("Could not create ModelContainer even after store reset: \(error)")
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                #if os(visionOS)
                VisionGalleryScreen()
                #else
                LibraryGridView()
                #endif
            }
            .onAppear {
                CollectionDefaults.setupDefaultCollections(
                    context: sharedModelContainer.mainContext)
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
