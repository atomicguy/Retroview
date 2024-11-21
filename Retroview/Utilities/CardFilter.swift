//
//  CardFilter.swift
//  Retroview
//
//  Created by Adam Schuster on 11/19/24.
//

import Foundation
import SwiftData

struct CardFilter: Equatable {
    var searchText: String = ""
    var selectedAuthor: AuthorSchemaV1.Author?
    var selectedDate: DateSchemaV1.Date?
    var selectedSubject: SubjectSchemaV1.Subject?
    
    func applies(to card: CardSchemaV1.StereoCard) -> Bool {
        let matchesSearch = searchText.isEmpty ||
            card.titles.contains { $0.text.localizedCaseInsensitiveContains(searchText) }
        
        let matchesAuthor = selectedAuthor == nil ||
            card.authors.contains(selectedAuthor!)
        
        let matchesDate = selectedDate == nil ||
            card.dates.contains(selectedDate!)
        
        let matchesSubject = selectedSubject == nil ||
            card.subjects.contains(selectedSubject!)
        
        return matchesSearch && matchesAuthor && matchesDate && matchesSubject
    }
}
