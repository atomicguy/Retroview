//
//  RetroviewApp.swift
//  Retroview
//
//  Created by Adam Schuster on 4/6/24.
//

import SwiftUI
import SwiftData

@main
struct RetroviewApp: App {
    
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            CardSchemaV1.StereoCard.self,
            TitleSchemaV1.Title.self
        ])
        let config = ModelConfiguration("MyStereoviews", schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }

        print(URL.applicationSupportDirectory.path(percentEncoded: false))
    }()
    
    var body: some Scene {
        WindowGroup {
            CardCollectionScreen()
        }
        .modelContainer(sharedModelContainer)
    }
}
