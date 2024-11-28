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
    var sharedModelContainer: ModelContainer = {
        // Delete existing store files before creating new container
        deleteExistingStoreFiles()

        let schema = Schema([
            CardSchemaV1.StereoCard.self,
            TitleSchemaV1.Title.self,
            AuthorSchemaV1.Author.self,
            SubjectSchemaV1.Subject.self,
            DateSchemaV1.Date.self,
            CropSchemaV1.Crop.self,
        ])

        let modelConfiguration = ModelConfiguration(
            "MyStereoviews",
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            fatalError(
                "Could not create ModelContainer: \(error.localizedDescription)"
            )
        }
    }()

    var body: some Scene {
        WindowGroup {
            GalleryScreen()
        }
        .modelContainer(sharedModelContainer)
    }
}

extension RetroviewApp {
    static func deleteExistingStoreFiles() {
        // Get the container URL for the app
        guard
            let containerURL = FileManager.default.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            ).first
        else { return }

        let storeURL = containerURL.appendingPathComponent(
            "MyStereoviews.store")
        let shmURL = containerURL.appendingPathComponent(
            "MyStereoviews.store-shm")
        let walURL = containerURL.appendingPathComponent(
            "MyStereoviews.store-wal")

        let urls = [storeURL, shmURL, walURL]

        for url in urls {
            try? FileManager.default.removeItem(at: url)
            print("Attempted to delete: \(url.path)")
        }

        // Also try to remove any files in the Containers directory
        if let containerPath = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "net.atompowered.Retroview"
        ) {
            let storeURL =
                containerPath
                    .appendingPathComponent("Library")
                    .appendingPathComponent("Application Support")
                    .appendingPathComponent("MyStereoviews.store")
            try? FileManager.default.removeItem(at: storeURL)
            print("Attempted to delete container store: \(storeURL.path)")
        }
    }
}
