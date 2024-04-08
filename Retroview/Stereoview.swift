//
//  Stereoview.swift
//  Retroview
//
//  Created by Adam Schuster on 4/6/24.
//

import Foundation
import SwiftData

@Model
class Stereoview {
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
