//
//  PreviewSampleData.swift
//  Retroview
//
//  Created by Adam Schuster on 12/26/24.
//

import SwiftData
import SwiftUI

// Manages real-world sample data for previews
@MainActor
final class PreviewDataManager {
    static let shared = PreviewDataManager()
    
    private let storeName = "preview.store"
    private var modelContainer: ModelContainer?
    
    var previewStoreURL: URL {
        // Store preview data in the app bundle
        Bundle.main.url(forResource: storeName, withExtension: nil)
            // Fallback to application support directory
            ?? FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
                .first!
                .appendingPathComponent("PreviewData")
                .appendingPathComponent(storeName)
    }
    
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

        // Try using the bundled preview store
        if let bundledURL = Bundle.main.url(forResource: storeName, withExtension: nil) {
            do {
                // First verify the store file exists and is readable
                guard FileManager.default.isReadableFile(atPath: bundledURL.path) else {
                    print("⚠️ Preview store exists but is not readable")
                    throw NSError(domain: "PreviewStore", code: 1)
                }

                // Print schema information
                print("Schema contains the following models:")
                schema.entities.forEach { entity in
                    print("- \(entity.name)")
                }
                
                // Create and verify temp directory
                let tempDir = FileManager.default.temporaryDirectory
                    .appendingPathComponent(UUID().uuidString)
                
                try FileManager.default.createDirectory(
                    at: tempDir,
                    withIntermediateDirectories: true
                )
                
                print("📁 Created temp directory at: \(tempDir.path)")
                
                // Copy store files
                let tempStoreURL = tempDir.appendingPathComponent(storeName)
                let storeFiles = [
                    (bundledURL, tempStoreURL),
                    (bundledURL.appendingPathExtension("shm"), tempStoreURL.appendingPathExtension("shm")),
                    (bundledURL.appendingPathExtension("wal"), tempStoreURL.appendingPathExtension("wal"))
                ]
                
                for (source, destination) in storeFiles {
                    if FileManager.default.fileExists(atPath: source.path) {
                        try FileManager.default.copyItem(at: source, to: destination)
                        print("Copied \(source.lastPathComponent)")
                    }
                }
                
                print("📄 Copied store file to: \(tempStoreURL.path)")
                print("📊 Store file size: \(try FileManager.default.attributesOfItem(atPath: tempStoreURL.path)[.size] ?? 0) bytes")
                
                // Check file permissions
                let attributes = try FileManager.default.attributesOfItem(atPath: tempStoreURL.path)
                print("File permissions: \(attributes[.posixPermissions] ?? "unknown")")
                print("File owner: \(attributes[.ownerAccountName] ?? "unknown")")
                
                // Verify SQLite header
                if let handle = try? FileHandle(forReadingFrom: tempStoreURL),
                   let headerData = try? handle.read(upToCount: 16) {
                    let magicString = "SQLite format 3"
                    if let fileHeader = String(data: headerData.prefix(magicString.count), encoding: .utf8),
                       fileHeader == magicString {
                        print("✅ File appears to be valid SQLite database")
                    } else {
                        print("⚠️ File does not appear to be valid SQLite database")
                    }
                    try? handle.close()
                }
                
                if #available(macOS 14.0, *) {
                    let process = Process()
                    process.executableURL = URL(fileURLWithPath: "/usr/bin/sqlite3")
                    process.arguments = [tempStoreURL.path, "PRAGMA wal_checkpoint(FULL);"]
                    try process.run()
                    process.waitUntilExit()
                }
                
//                #if DEBUG
//                if #available(macOS 14.0, *) {
//                    let process = Process()
//                    process.executableURL = URL(fileURLWithPath: "/usr/bin/sqlite3")
//                    process.arguments = [tempStoreURL.path, ".tables"]
//                    
//                    let pipe = Pipe()
//                    process.standardOutput = pipe
//                    
//                    try process.run()
//                    process.waitUntilExit()
//                    
//                    if let data = try pipe.fileHandleForReading.readToEnd(),
//                       let output = String(data: data, encoding: .utf8) {
//                        print("SQLite tables in database:")
//                        print(output)
//                    }
//                }
//                #endif
                
                print("🔄 Attempting to create ModelContainer...")
                let container = try ModelContainer(
                    for: schema,
                    configurations: [ModelConfiguration(
                        url: tempStoreURL,
                        allowsSave: false
                    )]
                )
                
                // Verify the container has data
                let context = container.mainContext
                let descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
                let count = try context.fetch(descriptor).count
                
                print("📊 Found \(count) cards in preview store")
                
                if count > 0 {
                    modelContainer = container
                    return container
                }
            } catch {
                print("❌ Failed to load bundled preview store:")
                print("Error: \(error.localizedDescription)")
                dump(error) // This will print the full error structure
            }
        }
        
        // Fallback to in-memory container
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try ModelContainer(
            for: schema,
            configurations: [config]
        )
        try populateFallbackData(context: container.mainContext)
        modelContainer = container
        return container
    }

    private func populateFallbackData(context: ModelContext) throws {
        // Create simple sample data
        let title = TitleSchemaV1.Title(text: "Sample Preview Card")
        let author = AuthorSchemaV1.Author(name: "Preview Author")
        let subject = SubjectSchemaV1.Subject(name: "Preview Subject")
        let date = DateSchemaV1.Date(text: "1900")

        context.insert(title)
        context.insert(author)
        context.insert(subject)
        context.insert(date)

        // Create a few sample cards
        for i in 1...5 {
            let card = CardSchemaV1.StereoCard(
                uuid: UUID(),
                imageFrontId: "sample-\(i)-F",
                imageBackId: "sample-\(i)-B"
            )

            // Add relationships
            card.titles = [title]
            card.authors = [author]
            card.subjects = [subject]
            card.dates = [date]
            card.titlePick = title

            // Add sample crops
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
        }

        let collection = CollectionSchemaV1.Collection(
            name: "Preview Collection")
        context.insert(collection)

        try context.save()
    }

    // Exports a subset of the current store for use in previews
    func exportPreviewStore(from sourceContext: ModelContext) async throws {
        print("\n📦 Starting preview store export...")

        // Create fresh store file
        try? FileManager.default.removeItem(at: previewStoreURL)
        try? FileManager.default.removeItem(
            at: previewStoreURL.appendingPathExtension("shm"))
        try? FileManager.default.removeItem(
            at: previewStoreURL.appendingPathExtension("wal"))

        try FileManager.default.createDirectory(
            at: previewStoreURL.deletingLastPathComponent(),
            withIntermediateDirectories: true
        )

        // Select sample cards from Favorites
        let favoritesName = CollectionDefaults.favoritesName
        var cardDescriptor = FetchDescriptor<CardSchemaV1.StereoCard>(
            predicate: #Predicate<CardSchemaV1.StereoCard> { card in
                card.collections.contains(where: { collection in
                    collection.name == favoritesName
                }) && card.imageFrontId != nil && card.imageBackId != nil
                    && !card.crops.isEmpty
            }
        )
        cardDescriptor.fetchLimit = 10

        let sampleCards = try sourceContext.fetch(cardDescriptor)
        print("Selected \(sampleCards.count) cards to export")

        // Create new store without copying binary data
        let schema = sourceContext.container.schema
        let config = ModelConfiguration(url: previewStoreURL)
        let container = try ModelContainer(
            for: schema, configurations: [config])
        let previewContext = container.mainContext

        for card in sampleCards {
            // Create new card with minimal data
            let newCard = CardSchemaV1.StereoCard(
                uuid: card.uuid,
                imageFrontId: card.imageFrontId,
                imageBackId: card.imageBackId,
                cardColor: card.cardColor,
                colorOpacity: card.colorOpacity
            )

            // Skip copying binary image data
            newCard.frontThumbnailData = nil
            newCard.frontStandardData = nil
            newCard.backThumbnailData = nil
            newCard.backStandardData = nil

            // Copy essential relationships
            if let title = card.titlePick {
                let newTitle = TitleSchemaV1.Title(text: title.text)
                previewContext.insert(newTitle)
                newCard.titles = [newTitle]
                newCard.titlePick = newTitle
            }

            if let author = card.authors.first {
                let newAuthor = AuthorSchemaV1.Author(name: author.name)
                previewContext.insert(newAuthor)
                newCard.authors = [newAuthor]
            }

            if let subject = card.subjects.first {
                let newSubject = SubjectSchemaV1.Subject(name: subject.name)
                previewContext.insert(newSubject)
                newCard.subjects = [newSubject]
            }

            if let date = card.dates.first {
                let newDate = DateSchemaV1.Date(text: date.text)
                previewContext.insert(newDate)
                newCard.dates = [newDate]
            }

            // Copy crops
            if let leftCrop = card.leftCrop {
                let newCrop = CropSchemaV1.Crop(
                    x0: leftCrop.x0, y0: leftCrop.y0,
                    x1: leftCrop.x1, y1: leftCrop.y1,
                    score: leftCrop.score, side: leftCrop.side
                )
                newCard.leftCrop = newCrop
            }

            if let rightCrop = card.rightCrop {
                let newCrop = CropSchemaV1.Crop(
                    x0: rightCrop.x0, y0: rightCrop.y0,
                    x1: rightCrop.x1, y1: rightCrop.y1,
                    score: rightCrop.score, side: rightCrop.side
                )
                newCard.rightCrop = newCrop
            }

            previewContext.insert(newCard)
        }

        // Create sample collection
        let collection = CollectionSchemaV1.Collection(
            name: "Sample Collection")
        previewContext.insert(collection)

        // Add cards to collection
        let allCards = try previewContext.fetch(
            FetchDescriptor<CardSchemaV1.StereoCard>())
        for card in allCards {
            collection.addCard(card, context: previewContext)
        }

        try previewContext.save()

        // Print statistics
        let fileSize =
            try FileManager.default.attributesOfItem(
                atPath: previewStoreURL.path)[.size] as? Int64 ?? 0

        print(
            """
            ✅ Preview store export complete:
            - Location: \(previewStoreURL.path)
            - Cards exported: \(allCards.count)
            - File size: \(ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file))
            """)

        // Reset container to use new store
        modelContainer = nil
    }

    private func copyCard(
        _ card: CardSchemaV1.StereoCard, to context: ModelContext
    ) async throws {
        // Create new card with same UUID
        let newCard = CardSchemaV1.StereoCard(
            uuid: card.uuid,
            imageFrontId: card.imageFrontId,
            imageBackId: card.imageBackId,
            cardColor: card.cardColor,
            colorOpacity: card.colorOpacity
        )

        // Copy image data
        newCard.frontThumbnailData = card.frontThumbnailData
        newCard.frontStandardData = card.frontStandardData
        newCard.backThumbnailData = card.backThumbnailData
        newCard.backStandardData = card.backStandardData

        // Copy or create relationships
        for title in card.titles {
            let newTitle = try await findOrCreateTitle(title.text, in: context)
            newCard.titles.append(newTitle)
        }

        if let titlePick = card.titlePick {
            newCard.titlePick = try await findOrCreateTitle(
                titlePick.text, in: context)
        }

        for author in card.authors {
            let newAuthor = try await findOrCreateAuthor(
                author.name, in: context)
            newCard.authors.append(newAuthor)
        }

        for subject in card.subjects {
            let newSubject = try await findOrCreateSubject(
                subject.name, in: context)
            newCard.subjects.append(newSubject)
        }

        for date in card.dates {
            let newDate = try await findOrCreateDate(date.text, in: context)
            newCard.dates.append(newDate)
        }

        // Copy crops by creating new ones with same values
        for crop in card.crops {
            let newCrop = CropSchemaV1.Crop(
                x0: crop.x0,
                y0: crop.y0,
                x1: crop.x1,
                y1: crop.y1,
                score: crop.score,
                side: crop.side
            )
            newCrop.card = newCard
            newCard.crops.append(newCrop)
            context.insert(newCrop)
        }

        context.insert(newCard)
    }

    private func findCard(_ uuid: UUID, in context: ModelContext) async throws
        -> CardSchemaV1.StereoCard?
    {
        let descriptor = FetchDescriptor<CardSchemaV1.StereoCard>(
            predicate: #Predicate<CardSchemaV1.StereoCard> { card in
                card.uuid == uuid
            }
        )
        return try context.fetch(descriptor).first
    }

    private func findOrCreateTitle(_ text: String, in context: ModelContext)
        async throws -> TitleSchemaV1.Title
    {
        let descriptor = FetchDescriptor<TitleSchemaV1.Title>(
            predicate: #Predicate<TitleSchemaV1.Title> { title in
                title.text == text
            }
        )

        if let existing = try context.fetch(descriptor).first {
            return existing
        }

        let new = TitleSchemaV1.Title(text: text)
        context.insert(new)
        return new
    }

    private func findOrCreateAuthor(_ name: String, in context: ModelContext)
        async throws -> AuthorSchemaV1.Author
    {
        let descriptor = FetchDescriptor<AuthorSchemaV1.Author>(
            predicate: #Predicate<AuthorSchemaV1.Author> { author in
                author.name == name
            }
        )

        if let existing = try context.fetch(descriptor).first {
            return existing
        }

        let new = AuthorSchemaV1.Author(name: name)
        context.insert(new)
        return new
    }

    private func findOrCreateSubject(_ name: String, in context: ModelContext)
        async throws -> SubjectSchemaV1.Subject
    {
        let descriptor = FetchDescriptor<SubjectSchemaV1.Subject>(
            predicate: #Predicate<SubjectSchemaV1.Subject> { subject in
                subject.name == name
            }
        )

        if let existing = try context.fetch(descriptor).first {
            return existing
        }

        let new = SubjectSchemaV1.Subject(name: name)
        context.insert(new)
        return new
    }

    private func findOrCreateDate(_ text: String, in context: ModelContext)
        async throws -> DateSchemaV1.Date
    {
        let descriptor = FetchDescriptor<DateSchemaV1.Date>(
            predicate: #Predicate<DateSchemaV1.Date> { date in
                date.text == text
            }
        )

        if let existing = try context.fetch(descriptor).first {
            return existing
        }

        let new = DateSchemaV1.Date(text: text)
        context.insert(new)
        return new
    }
}

// MARK: - View Extensions
extension View {
    func withPreviewStore() -> some View {
        let container = (try? PreviewDataManager.shared.container()) ?? {
            try! ModelContainer(
                for: CardSchemaV1.StereoCard.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
        }()
        return modelContainer(container)
    }
}

// MARK: - Preview Container
@MainActor
final class PreviewContainer {
    static let shared = PreviewContainer()
    
    let modelContainer: ModelContainer
    
    var modelContext: ModelContext {
        modelContainer.mainContext
    }
    
    private init() {
        do {
            // For previews, always use in-memory storage
            let schema = Schema([
                CardSchemaV1.StereoCard.self,
                TitleSchemaV1.Title.self,
                AuthorSchemaV1.Author.self,
                SubjectSchemaV1.Subject.self,
                DateSchemaV1.Date.self,
                CropSchemaV1.Crop.self,
                CollectionSchemaV1.Collection.self,
            ])
            
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            modelContainer = try ModelContainer(for: schema, configurations: [config])
            
            // Populate with sample data
            populateSampleData(context: modelContainer.mainContext)
        } catch {
            fatalError("Could not create preview container: \(error)")
        }
    }
    
    private func populateSampleData(context: ModelContext) {
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
        for i in 1...5 {
            let card = CardSchemaV1.StereoCard(
                uuid: UUID(),
                imageFrontId: "sample-\(i)-F",
                imageBackId: "sample-\(i)-B"
            )
            
            card.titles = [title]
            card.authors = [author]
            card.subjects = [subject]
            card.dates = [date]
            card.titlePick = title
            
            // Add sample crops
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
        }
        
        // Create a test collection
        let collection = CollectionSchemaV1.Collection(name: "Test Collection")
        context.insert(collection)
        
        try? context.save()
    }
}

// MARK: - Preview Helper
extension View {
    func withPreviewContainer() -> some View {
        modelContainer(PreviewContainer.shared.modelContainer)
    }
}
