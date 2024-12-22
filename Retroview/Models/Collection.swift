//
//  Collection.swift
//  Retroview
//
//  Created by Adam Schuster on 11/27/24.
//

import Foundation
import OSLog
import SwiftData

private let logger = Logger(
    subsystem: "com.example.retroview", category: "CollectionModel")

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

        var cards: [CardSchemaV1.StereoCard] = []

        // Store as Set for O(1) lookup
        @Transient
        private var cardIdSet: Set<UUID>?

        // Maintain order separately
        var orderedCardIds: [UUID] = [] {
            didSet {
                cardIdSet = Set(orderedCardIds)
            }
        }

        init(name: String) {
            self.id = UUID()
            self.name = name
            self.createdAt = Date()
            self.updatedAt = Date()
        }

        // MARK: - Card Management
        @MainActor
        func addCard(_ card: CardSchemaV1.StereoCard, context: ModelContext) {
            logger.debug("Adding card \(card.uuid) to collection \(self.name)")

            // Use efficient Set lookup
            if cardIdSet == nil {
                cardIdSet = Set(orderedCardIds)
            }

            guard !cardIdSet!.contains(card.uuid) else {
                logger.debug("Card already exists in collection")
                return
            }

            // Update relationships
            cards.append(card)
            orderedCardIds.append(card.uuid)
            cardIdSet!.insert(card.uuid)
            updatedAt = Date()

            do {
                try context.save()
                logger.debug("Successfully saved card addition to collection")
            } catch {
                logger.error(
                    "Failed to save card addition: \(error.localizedDescription)"
                )
            }
        }

        @MainActor
        func removeCard(_ card: CardSchemaV1.StereoCard, context: ModelContext)
        {
            logger.debug(
                "Removing card \(card.uuid) from collection \(self.name)")

            // Use efficient Set lookup
            if cardIdSet == nil {
                cardIdSet = Set(orderedCardIds)
            }

            guard cardIdSet!.contains(card.uuid) else {
                logger.debug("Card not found in collection")
                return
            }

            // Update relationships
            cards.removeAll { $0.uuid == card.uuid }
            orderedCardIds.removeAll { $0 == card.uuid }
            cardIdSet!.remove(card.uuid)
            updatedAt = Date()

            do {
                try context.save()
                logger.debug("Successfully saved card removal from collection")
            } catch {
                logger.error(
                    "Failed to save card removal: \(error.localizedDescription)"
                )
            }
        }

        private func withTransaction(
            _ context: ModelContext, _ updates: () -> Void
        ) {
            updates()
            do {
                try context.save()
                logger.debug("Successfully saved changes to collection")
            } catch {
                logger.error(
                    "Failed to save changes: \(error.localizedDescription)")
            }
        }

        func hasCard(_ card: CardSchemaV1.StereoCard) -> Bool {
            if cardIdSet == nil {
                cardIdSet = Set(orderedCardIds)
            }
            return cardIdSet!.contains(card.uuid)
        }

        var orderedCards: [CardSchemaV1.StereoCard] {
            orderedCardIds.compactMap { id in
                cards.first { $0.uuid == id }
            }
        }
    }
}

extension CollectionSchemaV1.Collection: Identifiable {}
