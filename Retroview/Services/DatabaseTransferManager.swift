//
//  DatabaseTransferManager.swift
//  Retroview
//
//  Created by Adam Schuster on 12/14/24.
//

import Compression
import Foundation
import SwiftData

@Observable @MainActor
final class DatabaseTransferManager {
    private(set) var currentProgress: ImportProgress?
    private(set) var isProcessing = false
    private let exportService = DatabaseExportService()

    struct ImportProgress {
        enum Phase {
            case decompressing
            case clearingData
            case importingCards(completed: Int, total: Int)
            case importingCollections(completed: Int, total: Int)
            case saving

            var description: String {
                switch self {
                case .decompressing: "Decompressing data..."
                case .clearingData: "Clearing existing data..."
                case .importingCards(let completed, let total):
                    "Importing cards (\(completed)/\(total))..."
                case .importingCollections(let completed, let total):
                    "Importing collections (\(completed)/\(total))..."
                case .saving: "Saving changes..."
                }
            }
        }

        let phase: Phase
        let message: String

        init(_ phase: Phase) {
            self.phase = phase
            self.message = phase.description
        }
    }

    func exportDatabase(from context: ModelContext) async throws -> Data {
        isProcessing = true
        defer { isProcessing = false }

        let descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
        let collectionDescriptor = FetchDescriptor<
            CollectionSchemaV1.Collection
        >()

        let cards = try context.fetch(descriptor)
        let collections = try context.fetch(collectionDescriptor)

        let exportData = DatabaseExport(
            cards: cards.map(CardTransfer.init),
            collections: collections.map(CollectionTransfer.init),
            version: 1
        )

        return try await Task.detached(priority: .userInitiated) {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            encoder.dateEncodingStrategy = .iso8601

            let data = try encoder.encode(exportData)
            return try await self.exportService.compressDataForExport(data)
        }.value
    }

    func importDatabase(from data: Data, into context: ModelContext)
        async throws
    {
        isProcessing = true
        defer { isProcessing = false }

        // Decompress and decode
        currentProgress = ImportProgress(.decompressing)
        let exportData = try await Task.detached(priority: .userInitiated) {
            let decompressedData = try await self.exportService
                .decompressDataForImport(data)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(
                DatabaseExport.self, from: decompressedData)
        }.value

        // Clear existing data
        currentProgress = ImportProgress(.clearingData)
        try await clearExistingData(in: context)

        // Import cards in batches
        let batchSize = 1000
        var processedCards = 0

        for batch in stride(from: 0, to: exportData.cards.count, by: batchSize)
        {
            let end = min(batch + batchSize, exportData.cards.count)
            let cardBatch = exportData.cards[batch..<end]

            currentProgress = ImportProgress(
                .importingCards(
                    completed: processedCards,
                    total: exportData.cards.count
                ))

            try await withThrowingTaskGroup(
                of: (CardTransfer, CardSchemaV1.StereoCard).self
            ) { group in
                for cardTransfer in cardBatch {
                    group.addTask {
                        // Create the card in a detached context
                        let card = CardSchemaV1.StereoCard(
                            uuid: cardTransfer.uuid,
                            imageFrontId: cardTransfer.imageFrontId,
                            imageBackId: cardTransfer.imageBackId,
                            cardColor: cardTransfer.cardColor,
                            colorOpacity: cardTransfer.colorOpacity
                        )
                        return (cardTransfer, card)
                    }
                }

                // Process all cards on the MainActor where we have context access
                for try await (transfer, card) in group {
                    // Create and link all related entities
                    card.titles = try transfer.titles.map { text in
                        try getOrCreateTitle(text: text, context: context)
                    }

                    card.authors = try transfer.authors.map { name in
                        try getOrCreateAuthor(name: name, context: context)
                    }

                    card.subjects = try transfer.subjects.map { name in
                        try getOrCreateSubject(name: name, context: context)
                    }

                    card.dates = try transfer.dates.map { text in
                        try getOrCreateDate(text: text, context: context)
                    }

                    if let titlePickText = transfer.titlePick {
                        card.titlePick = try getOrCreateTitle(
                            text: titlePickText, context: context)
                    }

                    // Create crops
                    for cropTransfer in transfer.crops {
                        let crop = CropSchemaV1.Crop(
                            x0: cropTransfer.x0,
                            y0: cropTransfer.y0,
                            x1: cropTransfer.x1,
                            y1: cropTransfer.y1,
                            score: cropTransfer.score,
                            side: cropTransfer.side
                        )
                        card.crops.append(crop)
                        crop.card = card
                    }

                    context.insert(card)
                }
            }

            processedCards += cardBatch.count

            // Save periodically
            if processedCards % (batchSize * 5) == 0 {
                currentProgress = ImportProgress(.saving)
                try context.save()
            }
        }

        // Import collections with progress
        var processedCollections = 0
        for collectionTransfer in exportData.collections {
            currentProgress = ImportProgress(
                .importingCollections(
                    completed: processedCollections,
                    total: exportData.collections.count
                ))

            let collection = try await importCollection(
                from: collectionTransfer, into: context)
            context.insert(collection)
            processedCollections += 1
        }

        // Final save
        currentProgress = ImportProgress(.saving)
        try context.save()
    }

    private func importCollection(
        from transfer: CollectionTransfer,
        into context: ModelContext
    ) async throws -> CollectionSchemaV1.Collection {
        let collection = CollectionSchemaV1.Collection(name: transfer.name)
        collection.id = transfer.id
        collection.createdAt = transfer.createdAt
        collection.updatedAt = transfer.updatedAt

        collection.orderedCardIds = transfer.cardOrder.compactMap {
            UUID(uuidString: $0)
        }

        let cards = transfer.cardOrder.compactMap {
            uuidString -> CardSchemaV1.StereoCard? in
            guard let uuid = UUID(uuidString: uuidString) else { return nil }
            return CardSchemaV1.StereoCard(uuid: uuid)
        }
        collection.updateCards(cards)

        return collection
    }

    // Helper functions for creating related entities
    private func getOrCreateTitle(text: String, context: ModelContext) throws
        -> TitleSchemaV1.Title
    {
        let descriptor = FetchDescriptor(
            predicate: ModelPredicates.Title.matching(text))
        if let existing = try context.fetch(descriptor).first {
            return existing
        }
        let title = TitleSchemaV1.Title(text: text)
        context.insert(title)
        return title
    }

    private func getOrCreateAuthor(name: String, context: ModelContext) throws
        -> AuthorSchemaV1.Author
    {
        let descriptor = FetchDescriptor(
            predicate: ModelPredicates.Author.withName(name))
        if let existing = try context.fetch(descriptor).first {
            return existing
        }
        let author = AuthorSchemaV1.Author(name: name)
        context.insert(author)
        return author
    }

    private func getOrCreateSubject(name: String, context: ModelContext) throws
        -> SubjectSchemaV1.Subject
    {
        let descriptor = FetchDescriptor(
            predicate: ModelPredicates.Subject.withName(name))
        if let existing = try context.fetch(descriptor).first {
            return existing
        }
        let subject = SubjectSchemaV1.Subject(name: name)
        context.insert(subject)
        return subject
    }

    private func getOrCreateDate(text: String, context: ModelContext) throws
        -> DateSchemaV1.Date
    {
        let descriptor = FetchDescriptor(
            predicate: ModelPredicates.Date.matching(text))
        if let existing = try context.fetch(descriptor).first {
            return existing
        }
        let date = DateSchemaV1.Date(text: text)
        context.insert(date)
        return date
    }

    private func clearExistingData(in context: ModelContext) async throws {
        let cardDescriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
        let collectionDescriptor = FetchDescriptor<
            CollectionSchemaV1.Collection
        >()
        let titleDescriptor = FetchDescriptor<TitleSchemaV1.Title>()
        let authorDescriptor = FetchDescriptor<AuthorSchemaV1.Author>()
        let subjectDescriptor = FetchDescriptor<SubjectSchemaV1.Subject>()
        let dateDescriptor = FetchDescriptor<DateSchemaV1.Date>()

        // Delete everything
        try context.fetch(cardDescriptor).forEach(context.delete)
        try context.fetch(collectionDescriptor).forEach(context.delete)
        try context.fetch(titleDescriptor).forEach(context.delete)
        try context.fetch(authorDescriptor).forEach(context.delete)
        try context.fetch(subjectDescriptor).forEach(context.delete)
        try context.fetch(dateDescriptor).forEach(context.delete)

        try context.save()
    }
}

enum DatabaseTransferError: LocalizedError {
    case encodingFailed(String)
    case decodingFailed(String)
    case compressionFailed
    case decompressionFailed

    var errorDescription: String? {
        switch self {
        case .encodingFailed(let details):
            "Failed to encode database: \(details)"
        case .decodingFailed(let details):
            "Failed to decode database: \(details)"
        case .compressionFailed: "Failed to compress data"
        case .decompressionFailed: "Failed to decompress data"
        }
    }
}
