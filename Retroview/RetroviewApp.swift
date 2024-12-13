//
//  RetroviewApp.swift
//  Retroview
//
//  Created by Adam Schuster on 12/8/24.
//

import SwiftUI
import SwiftData

@main
struct RetroviewApp: App {
    let modelContainer: ModelContainer
    
    init() {
        do {
            let schema = Schema([
                StereoCard.self,
                Collection.self,
                Author.self,
                Subject.self,
                DateReference.self,
                StereoCrop.self
            ])
            
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )
            
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError("Could not initialize ModelContainer: \(error)")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ImportTestView()
        }
        .modelContainer(modelContainer)
    }
}

