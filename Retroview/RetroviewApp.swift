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
    let container: ModelContainer
    var body: some Scene {
        WindowGroup {
            CardCollectionScreen()
        }
        .modelContainer(container)
    }
    
    init() {
        let schema = Schema([CardSchemaV1.StereoCard.self, TitleSchemaV1.Title.self])
        let config = ModelConfiguration("MyStereoviews", schema: schema)
        do {
            container = try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Could not configure the container")
        }

        print(URL.applicationSupportDirectory.path(percentEncoded: false))
//        print(URL.documentsDirectory.path())
    }
}
