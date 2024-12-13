//
//  PersistenceService.swift
//  Retroview
//
//  Created by Adam Schuster on 12/11/24.
//

import SwiftData
import Foundation

@MainActor
final class PersistenceService {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func findOrCreateAuthor(name: String, authority: String?, authorityURI: URL?) throws -> Author {
        let descriptor = FetchDescriptor<Author>(
            predicate: #Predicate<Author> { author in
                author.name == name
            }
        )
        
        if let existing = try modelContext.fetch(descriptor).first {
            return existing
        }
        
        let author = Author(name: name, authority: authority, authorityURI: authorityURI)
        modelContext.insert(author)
        return author
    }
    
    func findOrCreateSubject(name: String, authority: String?, authorityURI: URL?, valueURI: URL?) throws -> Subject {
        let descriptor = FetchDescriptor<Subject>(
            predicate: #Predicate<Subject> { subject in
                subject.name == name
            }
        )
        
        if let existing = try modelContext.fetch(descriptor).first {
            return existing
        }
        
        let subject = Subject(name: name, authority: authority, authorityURI: authorityURI, valueURI: valueURI)
        modelContext.insert(subject)
        return subject
    }
    
    func findOrCreateDateReference(dateString: String, encoding: String?, point: String?, qualifier: String?) throws -> DateReference {
        let descriptor = FetchDescriptor<DateReference>(
            predicate: #Predicate<DateReference> { dateRef in
                dateRef.dateString == dateString
            }
        )
        
        if let existing = try modelContext.fetch(descriptor).first {
            return existing
        }
        
        let date = DateReference(
            date: Date(), // TODO: Implement date parsing
            dateString: dateString,
            encoding: encoding,
            point: point,
            qualifier: qualifier
        )
        modelContext.insert(date)
        return date
    }
    
    func findOrCreateCard(uuid: UUID) throws -> StereoCard {
        let descriptor = FetchDescriptor<StereoCard>(
            predicate: #Predicate<StereoCard> { card in
                card.uuid == uuid
            }
        )
        
        if let existing = try modelContext.fetch(descriptor).first {
            return existing
        }
        
        let card = StereoCard(uuid: uuid, titles: ["Untitled"])
        modelContext.insert(card)
        return card
    }
    
    func save() throws {
        try modelContext.save()
    }
}
