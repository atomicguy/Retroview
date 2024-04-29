//
//  Stereoview.swift
//  Retroview
//
//  Created by Adam Schuster on 4/6/24.
//

import Foundation
import SwiftData

enum CardSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version = .init(2,0,0)
    
    static var models: [any PersistentModel.Type] {
        [StereoCard.self, TitleSchemaV1.Title.self, AuthorSchemaV1.Author.self, SubjectSchemaV1.Subject.self, DateSchemaV1.Date.self]
    }
    
    @Model
    class StereoCard {
        @Attribute(.unique) 
        var uuid: String
        @Relationship(inverse: \TitleSchemaV1.Title.cards)
        var titles: [TitleSchemaV1.Title]
        @Relationship(inverse: \AuthorSchemaV1.Author.cards)
        var authors: [AuthorSchemaV1.Author]
        @Relationship(inverse: \SubjectSchemaV1.Subject.cards)
        var subjects: [SubjectSchemaV1.Subject]
        @Relationship(inverse: \DateSchemaV1.Date.cards)
        var dates: [DateSchemaV1.Date]
        var rating: Int?
        var imageIdFront: String
        var imageIdBack: String?
        @Relationship(deleteRule: .cascade)
        var left: CropSchemaV1.Crop?
        @Relationship(deleteRule: .cascade)
        var right: CropSchemaV1.Crop?
        
        init(
            uuid: String,
            titles: [TitleSchemaV1.Title],
            authors: [AuthorSchemaV1.Author],
            subjects: [SubjectSchemaV1.Subject],
            dates: [DateSchemaV1.Date],
            rating: Int? = nil,
            imageIdFront: String,
            imageIdBack: String?,
            left: CropSchemaV1.Crop?,
            right: CropSchemaV1.Crop?
            
        ) {
            self.uuid = uuid
            self.titles = titles
            self.authors = authors
            self.subjects = subjects
            self.dates = dates
            self.rating = rating
            self.imageIdFront = imageIdFront
            self.imageIdBack = imageIdBack
            self.left = left
            self.right = right
        }
    }
}
