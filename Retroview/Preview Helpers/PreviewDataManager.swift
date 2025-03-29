//
//  PreviewSampleData.swift
//  Retroview
//
//  Created by Adam Schuster on 12/26/24.
//

import SwiftData
import SwiftUI

@MainActor
final class PreviewDataManager {
    static let shared = PreviewDataManager()
    private var modelContainer: ModelContainer?

    private init() {}

    func container() throws -> ModelContainer {
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

        // Try loading preview store
        if let container = try? loadPreviewStore(schema: schema) {
            modelContainer = container
            return container
        }
        
        // Fallback to in-memory
        let container = try ModelContainer(
            for: schema,
            configurations: [ModelConfiguration(isStoredInMemoryOnly: true)]
        )
        try populateFallbackData(context: container.mainContext)
        modelContainer = container
        return container
    }

    private func loadPreviewStore(schema: Schema) throws -> ModelContainer {
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        
        try FileManager.default.createDirectory(
            at: tempDir,
            withIntermediateDirectories: true
        )
        
        let storeFiles = ["store", "store-shm", "store-wal"]
        
        // Verify all files exist
        guard storeFiles.allSatisfy({ ext in
            Bundle.main.url(forResource: "preview", withExtension: ext) != nil
        }) else {
            throw PreviewStoreError.missingStoreFiles
        }
        
        // Copy all files
        try storeFiles.forEach { ext in
            let bundledURL = Bundle.main.url(forResource: "preview", withExtension: ext)!
            let tempURL = tempDir.appendingPathComponent("preview.\(ext)")
            try FileManager.default.copyItem(at: bundledURL, to: tempURL)
        }
        
        // Create and return container
        let config = ModelConfiguration(url: tempDir.appendingPathComponent("preview.store"))
        return try ModelContainer(for: schema, configurations: [config])
    }

    enum PreviewStoreError: Error {
        case missingStoreFiles
    }

    // Helper to provide single preview card
    func singleCard(_ predicate: ((CardSchemaV1.StereoCard) -> Bool)? = nil)
        -> CardSchemaV1.StereoCard?
    {
        do {
            let context = try container().mainContext
            let descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
            let cards = try context.fetch(descriptor)

            return predicate != nil
                ? cards.first(where: predicate!) : cards.first
        } catch {
            print("Error fetching preview card: \(error)")
            return nil
        }
    }

    private func populateFallbackData(context: ModelContext) throws {
        // Create basic sample data
        let title = TitleSchemaV1.Title(text: "Sample Preview Card")
        let author = AuthorSchemaV1.Author(name: "Preview Author")
        let subject = SubjectSchemaV1.Subject(name: "Preview Subject")
        let date = DateSchemaV1.Date(text: "1900")

        context.insert(title)
        context.insert(author)
        context.insert(subject)
        context.insert(date)

        // Create sample card
        let card = CardSchemaV1.StereoCard(
            uuid: UUID(),
            imageFrontId: "sample-F",
            imageBackId: "sample-B"
        )

        card.titles = [title]
        card.authors = [author]
        card.subjects = [subject]
        card.dates = [date]
        card.titlePick = title

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

        card.crops = [leftCrop, rightCrop]
        context.insert(card)

        // Create test collection
        let collection = CollectionSchemaV1.Collection(name: "Test Collection")
        context.insert(collection)

        try context.save()
    }
}

// MARK: - View Extensions
extension View {
    func withPreviewStore() -> some View {
        let container =
            (try? PreviewDataManager.shared.container())
            ?? {
                try! ModelContainer(
                    for: CardSchemaV1.StereoCard.self,
                    configurations: ModelConfiguration(
                        isStoredInMemoryOnly: true)
                )
            }()
        return modelContainer(container)
    }

    func withPreviewCard(
        _ predicate: ((CardSchemaV1.StereoCard) -> Bool)? = nil
    ) -> some View {
        let card = PreviewDataManager.shared.singleCard(predicate)
        return
            self
            .withPreviewStore()
            .environment(\.previewCard, card)
    }
}

// MARK: - Environment Key for Preview Card
private struct PreviewCardKey: EnvironmentKey {
    static let defaultValue: CardSchemaV1.StereoCard? = nil
}

extension EnvironmentValues {
    var previewCard: CardSchemaV1.StereoCard? {
        get { self[PreviewCardKey.self] }
        set { self[PreviewCardKey.self] = newValue }
    }
}
