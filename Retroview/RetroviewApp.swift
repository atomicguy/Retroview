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
    init() {
        // Only clear store if development flag is set
        if DevelopmentFlags.shouldResetStore {
            print("Development flag set: Clearing store...")
            Self.forceDeleteStore()
        }
    }

    var sharedModelContainer: ModelContainer = {
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
            return try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
        } catch {
            print(
                "Failed to create ModelContainer: \(error.localizedDescription)"
            )
            print("Attempting to force delete and recreate store...")

            // If that fails, force delete the store and try again
            Self.forceDeleteStore()

            do {
                return try ModelContainer(
                    for: schema,
                    configurations: [modelConfiguration]
                )
            } catch {
                fatalError(
                    "Could not create ModelContainer even after store deletion: \(error.localizedDescription)"
                )
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            Group {
                #if os(visionOS)
                    VisionGalleryScreen()
                #else
                    GalleryScreen()
                #endif
            }
            .onAppear {
                CollectionDefaults.setupDefaultCollections(
                    context: sharedModelContainer.mainContext)
            }
        }
        .modelContainer(sharedModelContainer)
    }

    // More aggressive store deletion that runs before SwiftData initialization
    static func forceDeleteStore() {
        guard
            let appSupport = FileManager.default.urls(
                for: .applicationSupportDirectory, in: .userDomainMask
            ).first
        else {
            return
        }

        let paths = [
            "MyStereoviews.store",
            "MyStereoviews.store-shm",
            "MyStereoviews.store-wal",
            "default.store",
            "default.store-shm",
            "default.store-wal",
            "MyStereoviews",  // directory
        ]

        // Delete all possible store files and directories
        for path in paths {
            let url = appSupport.appendingPathComponent(path)
            try? FileManager.default.removeItem(at: url)
            print("Attempted to delete: \(url.path)")
        }

        // Delete app group container if used
        if let containerPath = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "net.atompowered.Retroview")
        {
            let groupPaths = [
                "Library/Application Support/MyStereoviews.store",
                "Library/Application Support/MyStereoviews.store-shm",
                "Library/Application Support/MyStereoviews.store-wal",
                "Library/Application Support/default.store",
                "Library/Application Support/default.store-shm",
                "Library/Application Support/default.store-wal",
            ]

            for path in groupPaths {
                let url = containerPath.appendingPathComponent(path)
                try? FileManager.default.removeItem(at: url)
                print("Attempted to delete group container: \(url.path)")
            }
        }
    }
}

// Move store management to a separate utility
extension RetroviewApp {
    static func clearAllData() {
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
            print("Deleted: \(url.path)")
        }

        // Clear app group container if used
        if let containerPath = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "net.atompowered.Retroview"
        ) {
            let storeURL =
                containerPath
                .appendingPathComponent("Library")
                .appendingPathComponent("Application Support")
                .appendingPathComponent("MyStereoviews.store")
            try? FileManager.default.removeItem(at: storeURL)
            print("Deleted container store: \(storeURL.path)")
        }
    }
}
