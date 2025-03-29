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
    let imageDownloadManager: ImageDownloadManager
    let imageLoader = CardImageLoader()
    let spatialPhotoManager: SpatialPhotoManager

    init() {
        // Handle any pending imports before initializing SwiftData
        StoreImportHandler.handlePendingImport()

        #if DEBUG
            ImportLogger.configure(logLevel: .debug)
        #else
            ImportLogger.configure(logLevel: .error)
        #endif
        
        // Initialize the image cache early
        _ = ImageCache.shared

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
            self.importManager = BackgroundImportManager(
                modelContext: container.mainContext)
            self.imageDownloadManager = ImageDownloadManager(
                modelContext: container.mainContext)
            self.spatialPhotoManager = SpatialPhotoManager(
                modelContext: container.mainContext)
        } catch {
            print(
                "Failed to create ModelContainer: \(error.localizedDescription)"
            )

            do {
                let container = try ModelContainer(
                    for: schema,
                    configurations: [modelConfiguration]
                )
                self.sharedModelContainer = container
                self.importManager = BackgroundImportManager(
                    modelContext: container.mainContext)
                self.imageDownloadManager = ImageDownloadManager(
                    modelContext: container.mainContext)
                self.spatialPhotoManager = SpatialPhotoManager(
                    modelContext: container.mainContext)
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
                    .environment(\.modelContext, sharedModelContainer.mainContext)
                    .modifier(SerifFontModifier())
            }
            .environment(
                \.spatialPhotoManager,
                SpatialPhotoManager(
                    modelContext: sharedModelContainer.mainContext)
            )
            .environment(\.imageDownloadManager, imageDownloadManager)
            .environment(\.importManager, importManager)
            .environment(\.imageLoader, imageLoader)
            .environment(
                \.platformFilePicker, PlatformFilePickerKey.defaultValue
            )
            .environment(
                \.stackThumbnailManager,
                StackThumbnailManager(context: sharedModelContainer.mainContext)
            )
            .onAppear {
                CollectionDefaults.setupDefaultCollections(
                    context: sharedModelContainer.mainContext)
            }
        }
        .modelContainer(sharedModelContainer)
        #if os(visionOS)
            .windowStyle(.plain)
        #endif
    }
}

private struct ImportManagerKey: EnvironmentKey {
    static let defaultValue: BackgroundImportManager? = nil
}

private struct ImageDownloadManagerKey: EnvironmentKey {
    static let defaultValue: ImageDownloadManager? = nil
}

private struct ImageLoaderKey: EnvironmentKey {
    static let defaultValue: CardImageLoader? = nil
}

private struct CreateCollectionKey: EnvironmentKey {
    static let defaultValue: ((CardSchemaV1.StereoCard) -> Void)? = nil

}

private struct CreateCollectionMultipleKey: EnvironmentKey {
    static let defaultValue: (([CardSchemaV1.StereoCard]) -> Void)? = nil
}

private struct CurrentCollectionKey: EnvironmentKey {
    static let defaultValue: CollectionSchemaV1.Collection? = nil
}

extension EnvironmentValues {
    var importManager: BackgroundImportManager? {
        get { self[ImportManagerKey.self] }
        set { self[ImportManagerKey.self] = newValue }
    }

    var imageDownloadManager: ImageDownloadManager? {
        get { self[ImageDownloadManagerKey.self] }
        set { self[ImageDownloadManagerKey.self] = newValue }
    }

    var imageLoader: CardImageLoader? {
        get { self[ImageLoaderKey.self] }
        set { self[ImageLoaderKey.self] = newValue }
    }

    var createCollection: ((CardSchemaV1.StereoCard) -> Void)? {
        get { self[CreateCollectionKey.self] }
        set { self[CreateCollectionKey.self] = newValue }
    }

    var createCollectionForMultiple: (([CardSchemaV1.StereoCard]) -> Void)? {
        get { self[CreateCollectionMultipleKey.self] }
        set { self[CreateCollectionMultipleKey.self] = newValue }
    }

    var currentCollection: CollectionSchemaV1.Collection? {
        get { self[CurrentCollectionKey.self] }
        set { self[CurrentCollectionKey.self] = newValue }
    }
}
