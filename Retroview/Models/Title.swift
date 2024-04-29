//
//  Titles.swift
//  Retroview
//
//  Created by Adam Schuster on 4/20/24.
//

import Foundation
import SwiftData

enum TitleSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version = .init(1,0,0)
    
    static var models: [any PersistentModel.Type] {
        [Title.self, CardSchemaV1.StereoCard.self]
    }
    
    @Model
    class Title {
        var text: String
        var selection: Bool?
        
        var cards: [CardSchemaV1.StereoCard]?
        
        init(
            text: String,
            selection: Bool? = false
        ) {
            self.text = text
            self.selection = selection
        }
    }
}
