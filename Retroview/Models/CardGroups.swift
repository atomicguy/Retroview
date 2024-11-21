//
//  CardGroups.swift
//  Retroview
//
//  Created by Adam Schuster on 11/19/24.
//

import Foundation
import SwiftData

enum CardGroupSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version = .init(1, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        [Group.self, CardSchemaV1.StereoCard.self]
    }
    
    @Model
    class Group {
        var name: String
        var createdAt: Date
        var cards: [CardSchemaV1.StereoCard]
        
        init(name: String, cards: [CardSchemaV1.StereoCard] = []) {
            self.name = name
            self.createdAt = .init()
            self.cards = cards
        }
    }
}
