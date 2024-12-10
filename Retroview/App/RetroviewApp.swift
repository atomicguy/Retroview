//
//  RetroviewApp.swift
//  Retroview
//
//  Created by Adam Schuster on 4/6/24.
//

import SwiftData
import SwiftUI

@main
struct RetroviewApp: App {
    private let modelContainer: ModelContainer
    
    init() {
        do {
            modelContainer = try ModelContainer(
                for: schemaV1,
                configurations: [
                    ModelConfiguration(isStoredInMemoryOnly: false)
                ]
            )
            
            #if DEBUG
            if DevelopmentFlags.shouldResetStore {
                try? StoreManager.shared.resetStore()
                DevelopmentFlags.reset()
            }
            #endif
            
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}

// Schema definition
private let schemaV1 = Schema([
    CardSchemaV1.StereoCard.self,
    TitleSchemaV1.Title.self,
    AuthorSchemaV1.Author.self,
    SubjectSchemaV1.Subject.self,
    DateSchemaV1.Date.self,
    CropSchemaV1.Crop.self,
    CollectionSchemaV1.Collection.self,
])


