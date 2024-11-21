//
//  GroupSerialization.swift
//  Retroview
//
//  Created by Adam Schuster on 11/19/24.
//

import Foundation
import SwiftData

struct SerializableGroup: Codable {
    let name: String
    let createdAt: Date
    let cards: [SerializableCard]
    
    struct SerializableCard: Codable {
        let uuid: UUID
        let imageFrontId: String?
        let imageBackId: String?
        let titles: [String]
        let authors: [String]
        let subjects: [String]
        let dates: [String]
        let crops: [SerializableCrop]
        
        struct SerializableCrop: Codable {
            let x0: Float
            let y0: Float
            let x1: Float
            let y1: Float
            let score: Float
            let side: String
        }
        
        init(from card: CardSchemaV1.StereoCard) {
            self.uuid = card.uuid
            self.imageFrontId = card.imageFrontId
            self.imageBackId = card.imageBackId
            self.titles = card.titles.map(\.text)
            self.authors = card.authors.map(\.name)
            self.subjects = card.subjects.map(\.name)
            self.dates = card.dates.map(\.text)
            self.crops = card.crops.map { crop in
                SerializableCrop(
                    x0: crop.x0,
                    y0: crop.y0,
                    x1: crop.x1,
                    y1: crop.y1,
                    score: crop.score,
                    side: crop.side
                )
            }
        }
    }
    
    @MainActor
    init(from group: CardGroupSchemaV1.Group) {
        self.name = group.name
        self.createdAt = group.createdAt
        self.cards = group.cards.map { SerializableCard(from: $0) }
    }
}
