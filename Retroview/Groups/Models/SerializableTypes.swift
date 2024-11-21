//
//  SerializableTypes.swift
//  Retroview
//
//  Created by Adam Schuster on 11/20/24.
//

import Foundation
import SwiftData

struct SerializableGroup: Codable {
    let name: String
    let createdAt: Date
    let cards: [SerializableCard]

    init(name: String, createdAt: Date, cards: [SerializableCard]) {
        self.name = name
        self.createdAt = createdAt
        self.cards = cards
    }

    @MainActor
    init(from group: CardGroupSchemaV1.Group) {
        self.name = group.name
        self.createdAt = group.createdAt
        self.cards = group.cards.map { SerializableCard(from: $0) }
    }

    struct SerializableCard: Codable {
        let uuid: UUID
        let imageFrontId: String?
        let imageBackId: String?
        let titles: [String]
        let authors: [String]
        let subjects: [String]
        let dates: [String]
        let crops: [SerializableCrop]

        init(
            uuid: UUID, imageFrontId: String?, imageBackId: String?,
            titles: [String], authors: [String], subjects: [String],
            dates: [String], crops: [SerializableCrop]
        ) {
            self.uuid = uuid
            self.imageFrontId = imageFrontId
            self.imageBackId = imageBackId
            self.titles = titles
            self.authors = authors
            self.subjects = subjects
            self.dates = dates
            self.crops = crops
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

        struct SerializableCrop: Codable {
            let x0: Float
            let y0: Float
            let x1: Float
            let y1: Float
            let score: Float
            let side: String

            init(
                x0: Float, y0: Float, x1: Float, y1: Float, score: Float,
                side: String
            ) {
                self.x0 = x0
                self.y0 = y0
                self.x1 = x1
                self.y1 = y1
                self.score = score
                self.side = side
            }
        }
    }
}
