//
//  MODSImporter.swift
//  Retroview
//
//  Created by Adam Schuster on 12/8/24.
//

import SwiftData
import Foundation

/// Handles importing MODS metadata into SwiftData models
class MODSImporter {
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    // MARK: - Title Processing
    
    struct MODSTitleInfo {
        let type: String?          // abbreviated, translated, etc.
        let title: String
        let subTitle: String?
        let partNumber: String?
        let partName: String?
        let nonSort: String?
        let language: String?
    }
    
    func processTitles(_ titleInfos: [MODSTitleInfo]) -> [String] {
        return titleInfos.map { titleInfo in
            var fullTitle = ""
            
            // Add nonSort if present
            if let nonSort = titleInfo.nonSort {
                fullTitle += nonSort + " "
            }
            
            // Add main title
            fullTitle += titleInfo.title
            
            // Add subtitle if present
            if let subTitle = titleInfo.subTitle {
                fullTitle += ": " + subTitle
            }
            
            // Add part information if present
            if let partNumber = titleInfo.partNumber {
                fullTitle += ", Part " + partNumber
            }
            
            if let partName = titleInfo.partName {
                fullTitle += ": " + partName
            }
            
            return fullTitle.trimmingCharacters(in: .whitespaces)
        }
    }
    
    // MARK: - Author Processing
    
    struct MODSNameInfo {
        let type: String?          // personal, corporate
        let nameParts: [String: String] // role: value
        let roles: [String]
        let authorityURI: String?
        let valueURI: String?
    }
    
    func processAuthors(_ nameInfos: [MODSNameInfo]) -> [Author] {
        var authors: [Author] = []
        
        for nameInfo in nameInfos {
            // Construct normalized author name
            let authorName: String
            
            if nameInfo.type == "personal" {
                // Handle personal name parts
                let family = nameInfo.nameParts["family"] ?? ""
                let given = nameInfo.nameParts["given"] ?? ""
                let terms = nameInfo.nameParts["termsOfAddress"] ?? ""
                
                authorName = [family, given, terms]
                    .filter { !$0.isEmpty }
                    .joined(separator: ", ")
            } else {
                // Handle corporate or other name types
                authorName = nameInfo.nameParts["corporate"] ?? nameInfo.nameParts["name"] ?? ""
            }
            
            // Check if author already exists
            if let existingAuthor = try? context.fetch(
                FetchDescriptor<Author>(
                    predicate: #Predicate<Author> { $0.name == authorName }
                )
            ).first {
                authors.append(existingAuthor)
            } else {
                let author = Author(name: authorName)
                authors.append(author)
            }
        }
        
        return authors
    }
    
    // MARK: - Subject Processing
    
    struct MODSSubjectInfo {
        let topic: String
        let geographic: String?
        let temporal: String?
        let authority: String?
        let authorityURI: String?
        let valueURI: String?
    }
    
    func processSubjects(_ subjectInfos: [MODSSubjectInfo]) -> [Subject] {
        var subjects: [Subject] = []
        
        for subjectInfo in subjectInfos {
            // Create compound subject if needed
            var subjectParts: [String] = []
            
            subjectParts.append(subjectInfo.topic)
            
            if let geographic = subjectInfo.geographic {
                subjectParts.append(geographic)
            }
            
            if let temporal = subjectInfo.temporal {
                subjectParts.append(temporal)
            }
            
            let subjectName = subjectParts.joined(separator: " -- ")
            
            // Check if subject already exists
            if let existingSubject = try? context.fetch(
                FetchDescriptor<Subject>(
                    predicate: #Predicate<Subject> { $0.name == subjectName }
                )
            ).first {
                subjects.append(existingSubject)
            } else {
                let subject = Subject(name: subjectName)
                subjects.append(subject)
            }
        }
        
        return subjects
    }
    
    // MARK: - Authority Control
    
    func normalizeAuthorityName(_ name: String, authority: String?) -> String {
        // Add authority control normalization logic here
        // This could involve:
        // - Standardizing name formats
        // - Looking up authorized forms
        // - Handling different authority sources
        return name
    }
}

// MARK: - Usage Example

extension MODSImporter {
    static func example(context: ModelContext) throws {
        let importer = MODSImporter(context: context)
        
        // Process titles
        let titleInfos = [
            MODSTitleInfo(
                type: nil,
                title: "Main Title",
                subTitle: "A Subtitle",
                partNumber: "1",
                partName: "Introduction",
                nonSort: "The",
                language: "eng"
            )
        ]
        
        let titles = importer.processTitles(titleInfos)
        
        // Process authors
        let nameInfos = [
            MODSNameInfo(
                type: "personal",
                nameParts: [
                    "family": "Smith",
                    "given": "John",
                    "termsOfAddress": "Dr."
                ],
                roles: ["photographer"],
                authorityURI: nil,
                valueURI: nil
            )
        ]
        
        let authors = importer.processAuthors(nameInfos)
        
        // Process subjects
        let subjectInfos = [
            MODSSubjectInfo(
                topic: "Photography",
                geographic: "New York",
                temporal: "1850-1900",
                authority: "lcsh",
                authorityURI: nil,
                valueURI: nil
            )
        ]
        
        let subjects = importer.processSubjects(subjectInfos)
        
        // Create a new StereoCard with the processed data
        let card = StereoCard(
            uuid: UUID(),
            titles: titles
        )
        
        // Add relationships
        authors.forEach { author in
            author.cards.append(card)
            card.authors.append(author)
        }
        
        subjects.forEach { subject in
            subject.cards.append(card)
            card.subjects.append(subject)
        }
        
        // Save to SwiftData
        context.insert(card)
        
        try context.save()
        
        // Print results for verification
        print("Created card with:")
        print("- Titles: \(titles.joined(separator: "; "))")
        print("- Authors: \(authors.map(\.name).joined(separator: "; "))")
        print("- Subjects: \(subjects.map(\.name).joined(separator: "; "))")
    }
}
