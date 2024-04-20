//
//  Stereoview.swift
//  Retroview
//
//  Created by Adam Schuster on 4/6/24.
//

import Foundation
import SwiftData

enum CardSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version = .init(1,0,0)
    
    static var models: [any PersistentModel.Type] {
        [Card.self]
    }
    
    @Model
    class Card {
        @Attribute(.unique) var uuid: String
        var titles: [String]
        var authors: [String]
        var subjects: [String]
        var dates: [String]
        var rating: Int?
        
        init(
            uuid: String,
            titles: [String],
            authors: [String],
            subjects: [String],
            dates: [String],
            rating: Int? = nil
        ) {
            self.uuid = uuid
            self.titles = titles
            self.authors = authors
            self.subjects = subjects
            self.dates = dates
            self.rating = rating
        }
    }
}

enum CardSchemaV2: VersionedSchema {
    static var versionIdentifier: Schema.Version = .init(2,0,0)
    
    static var models: [any PersistentModel.Type] {
        [Card.self, TitleSchemaV1.Title.self, AuthorSchemaV1.Author.self, SubjectSchemaV1.Subject.self, DateSchemaV1.Date.self]
    }
    
    @Model
    class Card {
        @Attribute(.unique) var uuid: String
        @Relationship(deleteRule: .cascade) var titles: [TitleSchemaV1.Title]
        var authors: [AuthorSchemaV1.Author]
        var subjects: [SubjectSchemaV1.Subject]
        var dates: [DateSchemaV1.Date]
        var rating: Int?
        
        init(
            uuid: String,
            titles: [TitleSchemaV1.Title],
            authors: [AuthorSchemaV1.Author],
            subjects: [SubjectSchemaV1.Subject],
            dates: [DateSchemaV1.Date],
            rating: Int? = nil
        ) {
            self.uuid = uuid
            self.titles = titles
            self.authors = authors
            self.subjects = subjects
            self.dates = dates
            self.rating = rating
        }
    }
}
