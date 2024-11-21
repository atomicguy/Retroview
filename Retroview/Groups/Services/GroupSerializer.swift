//
//  GroupSerializer.swift
//  Retroview
//
//  Created by Adam Schuster on 11/20/24.
//

import Foundation
import SwiftData

@MainActor
struct GroupSerializer {
    static func serialize(_ group: CardGroupSchemaV1.Group) throws -> Data {
        let serializableGroup = SerializableGroup(
            name: group.name,
            createdAt: group.createdAt,
            cards: group.cards.map {
                SerializableGroup.SerializableCard(from: $0)
            }
        )
        return try JSONEncoder().encode(serializableGroup)
    }

    static func deserialize(_ data: Data, into context: ModelContext) throws
        -> CardGroupSchemaV1.Group
    {
        let serializableGroup = try JSONDecoder().decode(
            SerializableGroup.self, from: data
        )

        // Create or find existing cards
        let cards = try serializableGroup.cards.map {
            cardData -> CardSchemaV1.StereoCard in
            let descriptor = FetchDescriptor<CardSchemaV1.StereoCard>(
                predicate: #Predicate<CardSchemaV1.StereoCard> { card in
                    card.uuid == cardData.uuid
                }
            )

            if let existingCard = try context.fetch(descriptor).first {
                return existingCard
            }

            // Create new card if it doesn't exist
            let card = CardSchemaV1.StereoCard(
                uuid: cardData.uuid.uuidString,
                imageFrontId: cardData.imageFrontId,
                imageBackId: cardData.imageBackId
            )

            // Create and associate metadata
            createMetadata(for: card, from: cardData, in: context)
            context.insert(card)
            return card
        }

        // Create the group
        let group = CardGroupSchemaV1.Group(
            name: serializableGroup.name,
            cards: cards
        )
        group.createdAt = serializableGroup.createdAt
        return group
    }

    private static func createMetadata(
        for card: CardSchemaV1.StereoCard,
        from cardData: SerializableGroup.SerializableCard,
        in context: ModelContext
    ) {
        // Titles
        for titleText in cardData.titles {
            let title = TitleSchemaV1.Title(text: titleText)
            context.insert(title)
            card.titles.append(title)
        }

        // Authors
        for authorName in cardData.authors {
            let author = AuthorSchemaV1.Author(name: authorName)
            context.insert(author)
            card.authors.append(author)
        }

        // Subjects
        for subjectName in cardData.subjects {
            let subject = SubjectSchemaV1.Subject(name: subjectName)
            context.insert(subject)
            card.subjects.append(subject)
        }

        // Dates
        for dateText in cardData.dates {
            let date = DateSchemaV1.Date(text: dateText)
            context.insert(date)
            card.dates.append(date)
        }

        // Crops
        for cropData in cardData.crops {
            let crop = CropSchemaV1.Crop(
                x0: cropData.x0,
                y0: cropData.y0,
                x1: cropData.x1,
                y1: cropData.y1,
                score: cropData.score,
                side: cropData.side
            )
            crop.card = card
            context.insert(crop)
        }
    }
}
