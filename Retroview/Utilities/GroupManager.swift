//
//  GroupManager.swift
//  Retroview
//
//  Created by Adam Schuster on 11/19/24.
//

import Foundation
import SwiftData

@MainActor
class GroupManager: ObservableObject {
    @Published var selectedGroup: CardGroupSchemaV1.Group?
    
    func createGroup(name: String, context: ModelContext) {
        let group = CardGroupSchemaV1.Group(name: name)
        context.insert(group)
        try? context.save()
    }
    
    func addCardsToGroup(_ cards: [CardSchemaV1.StereoCard], group: CardGroupSchemaV1.Group) {
        group.cards.append(contentsOf: cards)
    }
    
    func removeCardsFromGroup(_ cards: [CardSchemaV1.StereoCard], group: CardGroupSchemaV1.Group) {
        group.cards.removeAll(where: { cards.contains($0) })
    }
    
    func importGroup(from data: Data, into context: ModelContext) throws {
        let serializableGroup = try JSONDecoder().decode(SerializableGroup.self, from: data)
        
        // Create or find existing cards
        let cards = try serializableGroup.cards.map { cardData -> CardSchemaV1.StereoCard in
            // Check if card already exists
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
            cardData.titles.forEach { titleText in
                let title = TitleSchemaV1.Title(text: titleText)
                context.insert(title)
                card.titles.append(title)
            }
            
            cardData.authors.forEach { authorName in
                let author = AuthorSchemaV1.Author(name: authorName)
                context.insert(author)
                card.authors.append(author)
            }
            
            cardData.subjects.forEach { subjectName in
                let subject = SubjectSchemaV1.Subject(name: subjectName)
                context.insert(subject)
                card.subjects.append(subject)
            }
            
            cardData.dates.forEach { dateText in
                let date = DateSchemaV1.Date(text: dateText)
                context.insert(date)
                card.dates.append(date)
            }
            
            // Create crops
            cardData.crops.forEach { cropData in
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
            
            context.insert(card)
            return card
        }
        
        // Create the group
        let group = CardGroupSchemaV1.Group(
            name: serializableGroup.name,
            cards: cards
        )
        group.createdAt = serializableGroup.createdAt
        context.insert(group)
        
        try context.save()
    }
}
