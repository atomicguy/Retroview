//
//  DatabaseTransferManager.swift
//  Retroview
//
//  Created by Adam Schuster on 12/14/24.
//

import Foundation
import SwiftData
import Compression

@MainActor
final class DatabaseTransferManager {
    private let exportService = DatabaseExportService()
    
    func exportDatabase(from context: ModelContext) async throws -> Data {
        print("📤 Starting database export...")
        
        let descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
        let collectionDescriptor = FetchDescriptor<CollectionSchemaV1.Collection>()
        
        let cards = try context.fetch(descriptor)
        let collections = try context.fetch(collectionDescriptor)
        
        print("📊 Found \(cards.count) cards and \(collections.count) collections to export")
        
        let exportData = DatabaseExport(
            cards: cards.map(CardTransfer.init),
            collections: collections.map(CollectionTransfer.init),
            version: 1
        )
        
        return try await Task.detached(priority: .userInitiated) {
            print("🔄 Encoding export data...")
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            encoder.dateEncodingStrategy = .iso8601
            
            let data = try encoder.encode(exportData)
            print("✅ Successfully encoded \(data.count) bytes")
            
            print("🗜️ Compressing data...")
            let compressed = try await self.exportService.compressDataForExport(data)
            print("✅ Compressed to \(compressed.count) bytes")
            
            return compressed
        }.value
    }
    
    func importDatabase(from data: Data, into context: ModelContext) async throws {
        print("\n📥 Starting database import...")
        print("📦 Received \(data.count) bytes")
        
        let exportData = try await Task.detached(priority: .userInitiated) {
            print("🗜️ Decompressing data...")
            let decompressedData = try await self.exportService.decompressDataForImport(data)
            print("✅ Decompressed to \(decompressedData.count) bytes")
            
            print("🔄 Decoding data...")
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            // Try to read the raw JSON for debugging
            if let jsonString = String(data: decompressedData, encoding: .utf8) {
                print("📃 First 200 characters of JSON:", String(jsonString.prefix(200)))
            }
            
            return try decoder.decode(DatabaseExport.self, from: decompressedData)
        }.value
        
        print("✅ Successfully decoded database export")
        print("📊 Found \(exportData.cards.count) cards and \(exportData.collections.count) collections")
        
        try await clearExistingData(in: context)
        
        // Import cards
        for cardTransfer in exportData.cards {
            let card = CardSchemaV1.StereoCard(
                uuid: cardTransfer.uuid,
                imageFrontId: cardTransfer.imageFrontId,
                imageBackId: cardTransfer.imageBackId,
                cardColor: cardTransfer.cardColor,
                colorOpacity: cardTransfer.colorOpacity
            )
            
            // Create and link all related entities
            card.titles = try cardTransfer.titles.map { text in
                try getOrCreateTitle(text: text, context: context)
            }
            
            card.authors = try cardTransfer.authors.map { name in
                try getOrCreateAuthor(name: name, context: context)
            }
            
            card.subjects = try cardTransfer.subjects.map { name in
                try getOrCreateSubject(name: name, context: context)
            }
            
            card.dates = try cardTransfer.dates.map { text in
                try getOrCreateDate(text: text, context: context)
            }
            
            if let titlePickText = cardTransfer.titlePick {
                card.titlePick = try getOrCreateTitle(text: titlePickText, context: context)
            }
            
            // Create crops
            for cropTransfer in cardTransfer.crops {
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
        
        // Import collections
        for collectionTransfer in exportData.collections {
            let collection = CollectionSchemaV1.Collection(name: collectionTransfer.name)
            collection.id = collectionTransfer.id
            collection.createdAt = collectionTransfer.createdAt
            collection.updatedAt = collectionTransfer.updatedAt
            collection.updateCards(collectionTransfer.cardOrder.map { uuid in
                CardSchemaV1.StereoCard(uuid: uuid)
            })
            context.insert(collection)
        }
        
        try context.save()
    }
    
    // Helper methods remain the same but are now implicitly @MainActor
    private func getOrCreateTitle(text: String, context: ModelContext) throws -> TitleSchemaV1.Title {
        let descriptor = FetchDescriptor<TitleSchemaV1.Title>(
            predicate: #Predicate<TitleSchemaV1.Title> { title in
                title.text == text
            }
        )
        
        if let existing = try context.fetch(descriptor).first {
            return existing
        }
        
        let title = TitleSchemaV1.Title(text: text)
        context.insert(title)
        return title
    }
    
    private func getOrCreateAuthor(name: String, context: ModelContext) throws -> AuthorSchemaV1.Author {
        let descriptor = FetchDescriptor<AuthorSchemaV1.Author>(
            predicate: #Predicate<AuthorSchemaV1.Author> { author in
                author.name == name
            }
        )
        
        if let existing = try context.fetch(descriptor).first {
            return existing
        }
        
        let author = AuthorSchemaV1.Author(name: name)
        context.insert(author)
        return author
    }
    
    private func getOrCreateSubject(name: String, context: ModelContext) throws -> SubjectSchemaV1.Subject {
        let descriptor = FetchDescriptor<SubjectSchemaV1.Subject>(
            predicate: #Predicate<SubjectSchemaV1.Subject> { subject in
                subject.name == name
            }
        )
        
        if let existing = try context.fetch(descriptor).first {
            return existing
        }
        
        let subject = SubjectSchemaV1.Subject(name: name)
        context.insert(subject)
        return subject
    }
    
    private func getOrCreateDate(text: String, context: ModelContext) throws -> DateSchemaV1.Date {
        let descriptor = FetchDescriptor<DateSchemaV1.Date>(
            predicate: #Predicate<DateSchemaV1.Date> { date in
                date.text == text
            }
        )
        
        if let existing = try context.fetch(descriptor).first {
            return existing
        }
        
        let date = DateSchemaV1.Date(text: text)
        context.insert(date)
        return date
    }
    
    private func clearExistingData(in context: ModelContext) async throws {
        let cardDescriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
        let collectionDescriptor = FetchDescriptor<CollectionSchemaV1.Collection>()
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
    
    private func compressData(_ data: Data) throws -> Data {
        let sourceBufferSize = data.count
        let destinationBufferSize = sourceBufferSize
        let destinationBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: destinationBufferSize)
        defer { destinationBuffer.deallocate() }
        
        let compressedSize = data.withUnsafeBytes { sourceBuffer in
            guard let baseAddress = sourceBuffer.baseAddress else {
                return 0
            }
            return compression_encode_buffer(
                destinationBuffer,
                destinationBufferSize,
                baseAddress.assumingMemoryBound(to: UInt8.self),
                sourceBufferSize,
                nil,
                COMPRESSION_LZFSE
            )
        }
        
        guard compressedSize > 0 else {
            throw DatabaseTransferError.compressionFailed
        }
        
        return Data(bytes: destinationBuffer, count: compressedSize)
    }

    private func decompressData(_ data: Data) throws -> Data {
        let sourceBufferSize = data.count
        let destinationBufferSize = sourceBufferSize * 4  // Estimate decompressed size
        let destinationBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: destinationBufferSize)
        defer { destinationBuffer.deallocate() }
        
        let decompressedSize = data.withUnsafeBytes { sourceBuffer in
            guard let baseAddress = sourceBuffer.baseAddress else {
                return 0
            }
            return compression_decode_buffer(
                destinationBuffer,
                destinationBufferSize,
                baseAddress.assumingMemoryBound(to: UInt8.self),
                sourceBufferSize,
                nil,
                COMPRESSION_LZFSE
            )
        }
        
        guard decompressedSize > 0 else {
            throw DatabaseTransferError.decompressionFailed
        }
        
        return Data(bytes: destinationBuffer, count: decompressedSize)
    }
}

enum DatabaseTransferError: LocalizedError {
    case encodingFailed(String)
    case decodingFailed(String)
    case compressionFailed
    case decompressionFailed
    
    var errorDescription: String? {
        switch self {
        case .encodingFailed(let details): "Failed to encode database: \(details)"
        case .decodingFailed(let details): "Failed to decode database: \(details)"
        case .compressionFailed: "Failed to compress data"
        case .decompressionFailed: "Failed to decompress data"
        }
    }
}
