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
        // MARK: - Properties
        @Attribute(.unique) var id: UUID
        var name: String
        var createdAt: Date
        var updatedAt: Date
        
        @Relationship(deleteRule: .nullify)
        var cards: [CardSchemaV1.StereoCard] = []
        
        // Maintain order separately
        var orderedCardIds: [UUID] = []
        
        // MARK: - Initialization
        init(name: String) {
            self.id = UUID()
            self.name = name
            self.createdAt = Date()
            self.updatedAt = Date()
        }
        
        // MARK: - Card Management
        func addCard(_ card: CardSchemaV1.StereoCard) {
            guard !cards.contains(card) else { return }
            cards.append(card)
            orderedCardIds.append(card.uuid)
            updatedAt = Date()
        }
        
        func removeCard(_ card: CardSchemaV1.StereoCard) {
            cards.removeAll { $0 == card }
            orderedCardIds.removeAll { $0 == card.uuid }
            updatedAt = Date()
        }
        
        func hasCard(_ card: CardSchemaV1.StereoCard) -> Bool {
            cards.contains(card)
        }
        
        func moveCard(from source: Int, to destination: Int) {
            guard source >= 0, source < orderedCardIds.count,
                  destination >= 0, destination <= orderedCardIds.count else { return }
            
            let cardId = orderedCardIds.remove(at: source)
            orderedCardIds.insert(cardId, at: destination)
            updatedAt = Date()
        }
        
        func updateCards(_ newCards: [CardSchemaV1.StereoCard]) {
            cards = newCards
            orderedCardIds = newCards.map(\.uuid)
            updatedAt = Date()
        }
        
        // MARK: - Ordered Access
        var orderedCards: [CardSchemaV1.StereoCard] {
            orderedCardIds.compactMap { id in
                cards.first { $0.uuid == id }
            }
        }
    }
}

// MARK: - Identifiable Conformance

extension CollectionSchemaV1.Collection: Identifiable {}
