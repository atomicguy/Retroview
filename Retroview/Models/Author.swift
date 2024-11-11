//
//  Author.swift
//  Retroview
//
//  Created by Adam Schuster on 4/20/24.
//

import Foundation
import SwiftData

enum AuthorSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version = .init(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [AuthorSchemaV1.Author.self, CardSchemaV1.StereoCard.self]
    }

    @Model
    class Author {
        var name: String
        var cards: [CardSchemaV1.StereoCard] = []

        init(name: String) {
            self.name = name
        }

        static let sampleData = [
            Author(name: "Kilburn, B. W. (Benjamin West) (1827-1909)"),
            Author(name: "Baker & Record (Firm)"),
            Author(name: "Unknown"),
        ]
    }
}
