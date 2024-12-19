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


            self.sharedModelContainer = container
        } catch {
            // If initial creation fails, try cleaning up and creating again
            print(
                "Failed to create ModelContainer: \(error.localizedDescription)"
            )
            StoreUtility.resetStore()

            do {
                self.sharedModelContainer = try ModelContainer(
                    for: schema,
                    configurations: [modelConfiguration]
                )
            } catch {
                fatalError(
                    "Could not create ModelContainer even after store reset: \(error)"
                )
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            Group {
                LibraryGridView()
            }
            .environment(\.font, .system(.body, design: .serif))
            .onAppear {
                CollectionDefaults.setupDefaultCollections(
                    context: sharedModelContainer.mainContext)
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
