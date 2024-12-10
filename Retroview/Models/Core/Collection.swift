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

        // Store card UUIDs to maintain order
        var cardOrder: [String] = []

        // MARK: - Initialization

        init(name: String, cards: [CardSchemaV1.StereoCard] = []) {
            id = UUID()
            self.name = name
            createdAt = Date()
            updatedAt = Date()
            cardOrder = cards.map(\.uuid.uuidString)
        }

        // MARK: - Card Management

        func addCard(_ card: CardSchemaV1.StereoCard) {
            guard !hasCard(card) else { return }
            cardOrder.append(card.uuid.uuidString)
            updatedAt = Date()
        }

        func removeCard(_ card: CardSchemaV1.StereoCard) {
            guard let index = cardOrder.firstIndex(of: card.uuid.uuidString) else { return }
            cardOrder.remove(at: index)
            updatedAt = Date()
        }

        func hasCard(_ card: CardSchemaV1.StereoCard) -> Bool {
            cardOrder.contains(card.uuid.uuidString)
        }

        func updateCards(_ cards: [CardSchemaV1.StereoCard]) {
            cardOrder = cards.map(\.uuid.uuidString)
            updatedAt = Date()
        }

        func moveCard(from source: Int, to destination: Int) {
            guard source >= 0, source < cardOrder.count,
                  destination >= 0, destination <= cardOrder.count else { return }

            let card = cardOrder.remove(at: source)
            cardOrder.insert(card, at: destination)
            updatedAt = Date()
        }

        // MARK: - Card Access

        var cardUUIDs: [String] {
            cardOrder
        }

        func fetchCards(context: ModelContext) -> [CardSchemaV1.StereoCard] {
            guard !cardOrder.isEmpty else { return [] }

            // Create UUID objects from strings
            let cardUUIDObjects = cardOrder.compactMap { UUID(uuidString: $0) }

            // Create a predicate that specifically matches the UUIDs for this collection
            let descriptor = FetchDescriptor<CardSchemaV1.StereoCard>(
                predicate: #Predicate<CardSchemaV1.StereoCard> { card in
                    cardUUIDObjects.contains(card.uuid)
                }
            )

            // Fetch and maintain order
            let fetchedCards = (try? context.fetch(descriptor)) ?? []

            // Return cards in the exact order specified by cardOrder
            return cardOrder.compactMap { uuid in
                fetchedCards.first { $0.uuid.uuidString == uuid }
            }
        }
    }
}

// MARK: - Identifiable Conformance

extension CollectionSchemaV1.Collection: Identifiable {}
