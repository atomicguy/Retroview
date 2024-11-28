//
//  Collection.swift
//  Retroview
//
//  Created by Adam Schuster on 11/27/24.
//

import Foundation
import SwiftData

enum CollectionSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version = .init(1, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        [Collection.self]
    }
    
    @Model
    class Collection {
        @Attribute(.unique) var id: UUID
        var name: String
        var createdAt: Date
        var updatedAt: Date
        
        // Store card UUIDs to maintain order and handle deleted cards gracefully
        var cardOrder: String
        
        init(name: String, cards: [CardSchemaV1.StereoCard] = []) {
            self.id = UUID()
            self.name = name
            self.createdAt = Date()
            self.updatedAt = Date()
            self.cardOrder = cards.map { $0.uuid.uuidString }.joined(separator: ",")
        }
        
        // Helper to get the array of card UUIDs
        var cardUUIDs: [String] {
            cardOrder.isEmpty ? [] : cardOrder.split(separator: ",").map(String.init)
        }
        
        // Update the cards in the collection
        func updateCards(_ cards: [CardSchemaV1.StereoCard]) {
            self.cardOrder = cards.map { $0.uuid.uuidString }.joined(separator: ",")
            self.updatedAt = Date()
        }
        
        // Add a single card
        func addCard(_ card: CardSchemaV1.StereoCard) {
            var uuids = cardUUIDs
            if !uuids.contains(card.uuid.uuidString) {
                uuids.append(card.uuid.uuidString)
                self.cardOrder = uuids.joined(separator: ",")
                self.updatedAt = Date()
            }
        }
        
        // Remove a single card
        func removeCard(_ card: CardSchemaV1.StereoCard) {
            var uuids = cardUUIDs
            if let index = uuids.firstIndex(of: card.uuid.uuidString) {
                uuids.remove(at: index)
                self.cardOrder = uuids.joined(separator: ",")
                self.updatedAt = Date()
            }
        }
        
        func hasCard(_ card: CardSchemaV1.StereoCard) -> Bool {
            cardUUIDs.contains(card.uuid.uuidString)
        }
        
        static let sampleData = [
            Collection(name: "World's Fair"),
            Collection(name: "New York City"),
            Collection(name: "Natural Wonders")
        ]
    }
}

// MARK: - Collection Card Fetching
extension CollectionSchemaV1.Collection {
    func fetchCards(context: ModelContext) -> [CardSchemaV1.StereoCard] {
        let uuids = cardUUIDs
        guard !uuids.isEmpty else { return [] }
        
        // Create UUID objects from strings
        let cardUUIDObjects = uuids.compactMap { UUID(uuidString: $0) }
        
        // Fetch cards
        let descriptor = FetchDescriptor<CardSchemaV1.StereoCard>(
            predicate: #Predicate<CardSchemaV1.StereoCard> { card in
                cardUUIDObjects.contains(card.uuid)
            }
        )
        
        // Return cards in the correct order
        let fetchedCards = (try? context.fetch(descriptor)) ?? []
        return uuids.compactMap { uuid in
            fetchedCards.first { $0.uuid.uuidString == uuid }
        }
    }
}

extension CollectionSchemaV1.Collection: Identifiable { }
