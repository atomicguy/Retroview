//
//  Subject.swift
//  Retroview
//
//  Created by Adam Schuster on 4/20/24.
//

import Foundation
import SwiftData

enum SubjectSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version = .init(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [Subject.self, CardSchemaV1.StereoCard.self]
    }

    @Model
    class Subject {
        var name: String
        var cards: [CardSchemaV1.StereoCard]?

        init(name: String) {
            self.name = name
        }

        static let sampleData = [
            Subject(name: "Chicago (Ill.)"),
            Subject(name: "Illinois"),
            Subject(
                name: "World's Columbian Exposition (1893 : Chicago, Ill.)"),
            Subject(name: "Exhibitions"),
            Subject(name: "Saratoga Springs (N.Y.)"),
            Subject(name: "Springhouses"),
            Subject(name: "New York (State)"),
        ]
    }
}
