//
//  PreviewStoreManager.swift
//  Retroview
//
//  Created by Adam Schuster on 12/15/24.
//

import SwiftData
import SwiftUI

enum PreviewStoreError: LocalizedError {
    case noSourceStore
    case verificationFailed(String)
    case copyFailed(String)
    case accessDenied(String)

    var errorDescription: String? {
        switch self {
        case .noSourceStore:
            "Could not locate source store to copy"
        case .verificationFailed(let reason):
            "Store verification failed: \(reason)"
        case .copyFailed(let reason):
            "Failed to copy store: \(reason)"
        case .accessDenied(let reason):
            "Access denied: \(reason)"
        }
    }
}

@MainActor
final class PreviewStoreManager {
    static let shared = PreviewStoreManager()

    let previewStoreURL: URL = {
        let appSupport = FileManager.default.urls(
            for: .applicationSupportDirectory, in: .userDomainMask
        ).first!
        return appSupport.appendingPathComponent("PreviewData/preview.store")
    }()

    private var modelContainer: ModelContainer?

    private init() {}

    func previewContainer() throws -> ModelContainer {
        if let existing = modelContainer {
            return existing
        }

        let schema = Schema([
            CardSchemaV1.StereoCard.self,
            TitleSchemaV1.Title.self,
            AuthorSchemaV1.Author.self,
            SubjectSchemaV1.Subject.self,
            DateSchemaV1.Date.self,
            CropSchemaV1.Crop.self,
            CollectionSchemaV1.Collection.self,
        ])

        // First try loading from the preview store file
        if FileManager.default.fileExists(atPath: previewStoreURL.path) {
            do {
                let config = ModelConfiguration(
                    schema: schema,
                    url: previewStoreURL,
                    allowsSave: false
                )

                let container = try ModelContainer(
                    for: schema, configurations: [config])

                // Verify the container has data
                let context = container.mainContext
                let descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
                let count = try context.fetch(descriptor).count

                if count > 0 {
                    modelContainer = container
                    return container
                }
            } catch {
                print("Failed to load preview store: \(error)")
            }
        }

        // Fallback to in-memory sample data
        print("Creating in-memory preview container with sample data")
        let config = ModelConfiguration(
            schema: schema, isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: schema, configurations: [config])
        try populatePreviewData(context: container.mainContext)
        modelContainer = container
        return container
    }

    private func populatePreviewData(context: ModelContext) throws {
        // Create sample data
        let title = TitleSchemaV1.Title(text: "Sample Stereocard")
        let author = AuthorSchemaV1.Author(name: "Test Author")
        let subject = SubjectSchemaV1.Subject(name: "Test Subject")
        let date = DateSchemaV1.Date(text: "1900")

        context.insert(title)
        context.insert(author)
        context.insert(subject)
        context.insert(date)

        // Create 5 sample cards
        for _ in 1...5 {
            let card = CardSchemaV1.StereoCard(uuid: UUID())
            
            // Add relationships
            card.titles = [title]
            card.authors = [author]
            card.subjects = [subject]
            card.dates = [date]
            card.titlePick = title

            // Add crops
            let leftCrop = CropSchemaV1.Crop(
                x0: 0.0, y0: 0.0,
                x1: 0.5, y1: 1.0,
                score: 1.0,
                side: "left"
            )

            let rightCrop = CropSchemaV1.Crop(
                x0: 0.5, y0: 0.0,
                x1: 1.0, y1: 1.0,
                score: 1.0,
                side: "right"
            )

            card.leftCrop = leftCrop
            card.rightCrop = rightCrop

            context.insert(card)
        }

        // Create a test collection
        let collection = CollectionSchemaV1.Collection(name: "Test Collection")
//        let cards = try context.fetch(FetchDescriptor<CardSchemaV1.StereoCard>())
//        cards.forEach { collection.addCard($0, context: context) }
        context.insert(collection)

        try context.save()
    }

    private func createPlaceholderImage(number: Int) -> Data? {
        // Create a renderer for a simple gradient image with a number
        let renderer = ImageRenderer(
            content: ZStack {
                LinearGradient(
                    colors: [.blue.opacity(0.3), .purple.opacity(0.3)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                Text("\(number)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(width: 400, height: 200)
        )

        #if canImport(UIKit)
        return renderer.uiImage?.pngData()
        #elseif canImport(AppKit)
        return renderer.nsImage?.tiffRepresentation
        #else
        return nil
        #endif
    }

    func saveAsPreviewStore(from sourceContext: ModelContext) async throws {
        print("Saving current state as preview store...")
        
        // Ensure directory exists
        try FileManager.default.createDirectory(
            at: previewStoreURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )
        
        // Get the current store URL
        guard let sourceURL = sourceContext.container.configurations.first?.url else {
            throw PreviewStoreError.noSourceStore
        }
        
        print("Source store URL: \(sourceURL.path)")
        
        // Check if source store file exists
        guard FileManager.default.fileExists(atPath: sourceURL.path) else {
            throw PreviewStoreError.verificationFailed("Source store file not found at \(sourceURL.path)")
        }
        
        // Remove existing preview store files
        let storeURLs = [
            previewStoreURL,
            previewStoreURL.appendingPathExtension("shm"),
            previewStoreURL.appendingPathExtension("wal")
        ]
        
        for url in storeURLs {
            try? FileManager.default.removeItem(at: url)
        }
        
        // Wait for any pending operations
        try await Task.sleep(for: .milliseconds(100))
        
        // Copy store files
        try FileManager.default.copyItem(at: sourceURL, to: previewStoreURL)
        
        // Copy auxiliary files if they exist
        try? FileManager.default.copyItem(
            at: sourceURL.appendingPathExtension("shm"),
            to: previewStoreURL.appendingPathExtension("shm")
        )
        try? FileManager.default.copyItem(
            at: sourceURL.appendingPathExtension("wal"),
            to: previewStoreURL.appendingPathExtension("wal")
        )
        
        print("Preview store saved successfully")
        
        // Reset container to use new store
        modelContainer = nil
    }
}

// MARK: - Preview Container Helper
extension View {
    func withPreviewStore() -> some View {
        let container = (try? PreviewStoreManager.shared.previewContainer())
            ?? {
                try! ModelContainer(
                    for: CardSchemaV1.StereoCard.self,
                    configurations: ModelConfiguration(isStoredInMemoryOnly: true)
                )
            }()
        return modelContainer(container)
    }
}
