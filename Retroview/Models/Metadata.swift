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
    @Relationship(deleteRule: .nullify, inverse: \StereoCard.authors) var cards: [StereoCard]
    
    init(name: String) {
        self.name = name
        self.cards = []  // Initialize the relationship array
    }
}

// MARK: - Subject Model
@Model
final class Subject {
    @Attribute(.unique) var name: String
    @Relationship(deleteRule: .nullify, inverse: \StereoCard.subjects) var cards: [StereoCard]
    
    init(name: String) {
        self.name = name
        self.cards = []  // Initialize the relationship array
    }
}

// MARK: - DateReference Model
@Model
final class DateReference {
    var date: Date
    var dateString: String
    @Relationship(deleteRule: .nullify, inverse: \StereoCard.dates) var cards: [StereoCard]
    
    init(date: Date, dateString: String) {
        self.date = date
        self.dateString = dateString
        self.cards = []  // Initialize the relationship array
    }
}
