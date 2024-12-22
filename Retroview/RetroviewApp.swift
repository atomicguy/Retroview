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
    let importManager: BackgroundImportManager
    
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
            self.importManager = BackgroundImportManager(modelContext: container.mainContext)

        } catch {
            print("Failed to create ModelContainer: \(error.localizedDescription)")
            StoreUtility.resetStore()

            do {
                let container = try ModelContainer(
                    for: schema,
                    configurations: [modelConfiguration]
                )
                self.sharedModelContainer = container
                self.importManager = BackgroundImportManager(modelContext: container.mainContext)
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
                MainView()
            }
            .environment(\.font, .system(.body, design: .serif))
            .environment(\.importManager, importManager)
            .onAppear {
                CollectionDefaults.setupDefaultCollections(
                    context: sharedModelContainer.mainContext)
            }
        }
        .modelContainer(sharedModelContainer)
    }
}

private struct ImportManagerKey: EnvironmentKey {
    static let defaultValue: BackgroundImportManager? = nil
}

extension EnvironmentValues {
    var importManager: BackgroundImportManager? {
        get { self[ImportManagerKey.self] }
        set { self[ImportManagerKey.self] = newValue }
    }
}
