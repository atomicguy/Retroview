//
//  Collection.swift
//  Retroview
//
//  Created by Adam Schuster on 12/8/24.
//

import SwiftData
import Foundation

@Model
final class Collection {
    // MARK: - Properties
    @Attribute(.unique) var id: UUID
    var name: String
    var createdAt: Date
    var updatedAt: Date
    
    @Relationship(deleteRule: .nullify, inverse: \StereoCard.collections)
    var cards: [StereoCard]
    
    // MARK: - Initialization
    init(id: UUID = UUID(),
         name: String,
         cards: [StereoCard] = []) {
        self.id = id
        self.name = name
        self.createdAt = Date()
        self.updatedAt = Date()
        self.cards = cards
    }
    
    // MARK: - Card Management
    func addCard(_ card: StereoCard) {
        guard !cards.contains(card) else { return }
        cards.append(card)
        updatedAt = Date()
    }
    
    func removeCard(_ card: StereoCard) {
        cards.removeAll { $0.uuid == card.uuid }
        updatedAt = Date()
    }
}
