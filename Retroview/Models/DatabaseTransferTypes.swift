//
//  DatabaseTransferTypes.swift
//  Retroview
//
//  Created by Adam Schuster on 12/14/24.
//

import Foundation
import SwiftData

// MARK: - Transfer Types
struct CardTransfer: Codable {
    let uuid: String
    let imageFrontId: String?
    let imageBackId: String?
    let cardColor: String
    let colorOpacity: Double
    let titles: [String]  // Just store the text values
    let authors: [String] // Just store the names
    let subjects: [String] // Just store the names
    let dates: [String] // Just store the text values
    let titlePick: String? // Store the picked title text
    let crops: [CropTransfer]
    
    init(from card: CardSchemaV1.StereoCard) {
        uuid = card.uuid.uuidString
        imageFrontId = card.imageFrontId
        imageBackId = card.imageBackId
        cardColor = card.cardColor
        colorOpacity = card.colorOpacity
        titles = card.titles.map(\.text)
        authors = card.authors.map(\.name)
        subjects = card.subjects.map(\.name)
        dates = card.dates.map(\.text)
        titlePick = card.titlePick?.text
        crops = card.crops.map(CropTransfer.init)
    }
}

struct CropTransfer: Codable {
    let x0: Float
    let y0: Float
    let x1: Float
    let y1: Float
    let score: Float
    let side: String
    
    init(from crop: CropSchemaV1.Crop) {
        x0 = crop.x0
        y0 = crop.y0
        x1 = crop.x1
        y1 = crop.y1
        score = crop.score
        side = crop.side
    }
}

struct CollectionTransfer: Codable {
    let id: UUID
    let name: String
    let createdAt: Date
    let updatedAt: Date
    let cardOrder: [String]
    
    init(from collection: CollectionSchemaV1.Collection) {
        id = collection.id
        name = collection.name
        createdAt = collection.createdAt
        updatedAt = collection.updatedAt
        cardOrder = collection.cardUUIDs
    }
}

// MARK: - Database Export Format
struct DatabaseExport: Codable {
    let cards: [CardTransfer]
    let collections: [CollectionTransfer]
    let version: Int
    
    init(cards: [CardTransfer], collections: [CollectionTransfer], version: Int = 1) {
        self.cards = cards
        self.collections = collections
        self.version = version
    }
}
