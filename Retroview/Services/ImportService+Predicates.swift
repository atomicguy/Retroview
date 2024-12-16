//
//  ImportService+Predicates.swift
//  Retroview
//
//  Created by Adam Schuster on 12/15/24.
//

import Foundation
import SwiftData

extension ImportService {
    func cardExists(uuid: UUID) throws -> Bool {
        let descriptor = FetchDescriptor<CardSchemaV1.StereoCard>(
            predicate: #Predicate<CardSchemaV1.StereoCard> { card in
                card.uuid == uuid
            }
        )
        return try modelContext.fetch(descriptor).first != nil
    }
    
    func findTitle(matching text: String) throws -> TitleSchemaV1.Title? {
        let descriptor = FetchDescriptor<TitleSchemaV1.Title>(
            predicate: #Predicate<TitleSchemaV1.Title> { title in
                title.text == text
            }
        )
        return try modelContext.fetch(descriptor).first
    }
    
    func findAuthor(matching name: String) throws -> AuthorSchemaV1.Author? {
        let descriptor = FetchDescriptor<AuthorSchemaV1.Author>(
            predicate: #Predicate<AuthorSchemaV1.Author> { author in
                author.name == name
            }
        )
        return try modelContext.fetch(descriptor).first
    }
    
    func findSubject(matching name: String) throws -> SubjectSchemaV1.Subject? {
        let descriptor = FetchDescriptor<SubjectSchemaV1.Subject>(
            predicate: #Predicate<SubjectSchemaV1.Subject> { subject in
                subject.name == name
            }
        )
        return try modelContext.fetch(descriptor).first
    }
    
    func findDate(matching text: String) throws -> DateSchemaV1.Date? {
        let descriptor = FetchDescriptor<DateSchemaV1.Date>(
            predicate: #Predicate<DateSchemaV1.Date> { date in
                date.text == text
            }
        )
        return try modelContext.fetch(descriptor).first
    }
}
