//
//  Author.swift
//  Retroview
//
//  Created by Adam Schuster on 4/20/24.
//

import Foundation
import SwiftData

enum AuthorSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version = .init(1,0,0)
    
    static var models: [any PersistentModel.Type] {
        [Author.self]
    }
    
    @Model
    class Author {
        var name: String
        
        init(name: String) {
            self.name = name
        }
    }
}
