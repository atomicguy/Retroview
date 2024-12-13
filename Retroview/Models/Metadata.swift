//
//  Metadata.swift
//  Retroview
//
//  Created by Adam Schuster on 12/8/24.
//

import SwiftData
import Foundation

// MARK: - Author Model
@Model
final class Author {
    @Attribute(.unique) var name: String
    var authority: String?
    var authorityURI: URL?
    
    @Relationship(deleteRule: .nullify, inverse: \StereoCard.authors)
    var cards: [StereoCard]
    
    init(name: String, authority: String? = nil, authorityURI: URL? = nil) {
        self.name = name
        self.authority = authority
        self.authorityURI = authorityURI
        self.cards = []
    }
}

// MARK: - Subject Model
@Model
final class Subject {
    @Attribute(.unique) var name: String
    var authority: String?
    var authorityURI: URL?
    var valueURI: URL?
    
    @Relationship(deleteRule: .nullify, inverse: \StereoCard.subjects)
    var cards: [StereoCard]
    
    init(name: String, authority: String? = nil, authorityURI: URL? = nil, valueURI: URL? = nil) {
        self.name = name
        self.authority = authority
        self.authorityURI = authorityURI
        self.valueURI = valueURI
        self.cards = []
    }
}

// MARK: - DateReference Model
@Model
final class DateReference {
    var date: Date
    var dateString: String
    var encoding: String?
    var point: String?  // "start" or "end" for date ranges
    var qualifier: String? // "approximate", "inferred", or "questionable"
    
    @Relationship(deleteRule: .nullify, inverse: \StereoCard.dates)
    var cards: [StereoCard]
    
    init(date: Date,
         dateString: String,
         encoding: String? = nil,
         point: String? = nil,
         qualifier: String? = nil) {
        self.date = date
        self.dateString = dateString
        self.encoding = encoding
        self.point = point
        self.qualifier = qualifier
        self.cards = []
    }
}
