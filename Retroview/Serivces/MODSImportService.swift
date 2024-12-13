//
//  MODSImportService.swift
//  Retroview
//
//  Created by Adam Schuster on 12/11/24.
//

import Foundation
import SwiftData

@MainActor
final class MODSImportService {
    private let persistenceService: PersistenceService
    
    init(modelContext: ModelContext) {
        self.persistenceService = PersistenceService(modelContext: modelContext)
    }
    
    func importCard(from modsData: Data) async throws -> StereoCard {
        let cardData = try await parseModsData(modsData)
        return try await createOrUpdateCard(from: cardData)
    }
    
    private func createOrUpdateCard(from data: ParsedCardData) async throws -> StereoCard {
        // Get or create the base card
        let card = try persistenceService.findOrCreateCard(uuid: data.uuid)
        
        // Update basic properties
        card.titles = data.titles
        card.primaryTitle = data.titles.first ?? "Untitled"
        card.notes = data.notes
        card.rightsStatement = data.rightsStatement
        card.modsIdentifiers = data.identifiers
        
        // Create relationships one at a time to avoid predicate issues
        var authors: [Author] = []
        for authorData in data.authors {
            let author = try persistenceService.findOrCreateAuthor(
                name: authorData.name,
                authority: authorData.authority,
                authorityURI: authorData.authorityURI
            )
            authors.append(author)
        }
        card.authors = authors
        
        var subjects: [Subject] = []
        for subjectData in data.subjects {
            let subject = try persistenceService.findOrCreateSubject(
                name: subjectData.name,
                authority: subjectData.authority,
                authorityURI: subjectData.authorityURI,
                valueURI: subjectData.valueURI
            )
            subjects.append(subject)
        }
        card.subjects = subjects
        
        var dates: [DateReference] = []
        for dateData in data.dates {
            let date = try persistenceService.findOrCreateDateReference(
                dateString: dateData.dateString,
                encoding: dateData.encoding,
                point: dateData.point,
                qualifier: dateData.qualifier
            )
            dates.append(date)
        }
        card.dates = dates
        
        try persistenceService.save()
        return card
    }
}

// MARK: - Background Parsing
extension MODSImportService {
    private func parseModsData(_ data: Data) async throws -> ParsedCardData {
        try await Task.detached {
            let decoder = JSONDecoder()
            let response = try decoder.decode(MODSResponse.self, from: data)

            guard let uuid = try await Self.extractUUID(from: response) else {
                throw MODSImportError.missingUUID
            }

            return await ParsedCardData(
                uuid: uuid,
                titles: Self.extractTitles(from: response),
                authors: Self.extractAuthors(from: response),
                subjects: Self.extractSubjects(from: response),
                dates: Self.extractDates(from: response),
                notes: Self.extractNotes(from: response),
                rightsStatement: Self.extractRightsStatement(from: response),
                identifiers: Self.extractIdentifiers(from: response)
            )
        }.value
    }
    
    private static func extractUUID(from response: MODSResponse) throws -> UUID? {
        guard let identifiers = response.card.nyplAPI.response.mods.identifier else {
            return nil
        }

        for identifierGroup in identifiers {
            for identifier in identifierGroup {
                if identifier.type == "uuid", let uuidString = identifier.x_ {
                    return UUID(uuidString: uuidString)
                }
            }
        }
        return nil
    }

    private static func extractTitles(from response: MODSResponse) -> [String] {
        var titles: [String] = []

        if let title = response.card.nyplAPI.response.mods.titleInfo.title?.x_ {
            titles.append(title)
        }

        return titles.isEmpty ? ["Untitled"] : titles
    }

    private static func extractAuthors(from response: MODSResponse) -> [AuthorData] {
        guard let nameContent = response.card.nyplAPI.response.mods.name,
            let authorName = nameContent.namePart?.x_
        else {
            return []
        }

        return [
            AuthorData(
                name: authorName,
                authority: nameContent.authority,
                authorityURI: URL(string: nameContent.valueURI ?? "")
            )
        ]
    }

    private static func extractSubjects(from response: MODSResponse) -> [SubjectData] {
        var subjects: [SubjectData] = []
        
        if let subjectGroups = response.card.nyplAPI.response.mods.subject {
            for subjectGroup in subjectGroups {
                for subjectContent in subjectGroup {
                    if let topic = subjectContent.topic,
                       let name = topic.x_ {
                        subjects.append(
                            SubjectData(
                                name: name,
                                authority: topic.authority,
                                authorityURI: URL(string: topic.valueURI ?? ""),
                                valueURI: nil
                            )
                        )
                    }
                    
                    if let geographic = subjectContent.geographic,
                       let name = geographic.x_ {
                        subjects.append(
                            SubjectData(
                                name: name,
                                authority: geographic.authority,
                                authorityURI: URL(string: geographic.valueURI ?? ""),
                                valueURI: nil
                            )
                        )
                    }
                }
            }
        }
        
        return subjects
    }
    private static func extractDates(from response: MODSResponse) -> [DateData] {
        var dates: [DateData] = []

        if let originInfo = response.card.nyplAPI.response.mods.originInfo?.first,
            let dateCreated = originInfo.dateCreated {
            for dateInfo in dateCreated {
                if let dateString = dateInfo.x_ {
                    dates.append(
                        DateData(
                            dateString: dateString,
                            encoding: dateInfo.encoding,
                            point: dateInfo.point,
                            qualifier: dateInfo.qualifier
                        ))
                }
            }
        }

        return dates
    }

    private static func extractNotes(from response: MODSResponse) -> [String] {
        var notes: [String] = []

        if let noteGroups = response.card.nyplAPI.response.mods.note {
            for noteGroup in noteGroups {
                for note in noteGroup {
                    if let noteText = note.x_ {
                        notes.append(noteText)
                    }
                }
            }
        }

        return notes
    }

    private static func extractRightsStatement(from response: MODSResponse) -> String? {
        guard let captures = response.card.nyplAPI.response.capture.first,
            let firstCapture = captures.first
        else {
            return nil
        }
        return firstCapture.rightsStatement.x_
    }

    private static func extractIdentifiers(from response: MODSResponse) -> [String: String] {
        var identifiers: [String: String] = [:]

        if let identifierGroups = response.card.nyplAPI.response.mods.identifier {
            for identifierGroup in identifierGroups {
                for identifier in identifierGroup {
                    if let type = identifier.type,
                        let value = identifier.x_
                    {
                        identifiers[type] = value
                    }
                }
            }
        }

        return identifiers
    }
}

// MARK: - Data Transfer Objects
struct ParsedCardData: Sendable {
    let uuid: UUID
    let titles: [String]
    let authors: [AuthorData]
    let subjects: [SubjectData]
    let dates: [DateData]
    let notes: [String]
    let rightsStatement: String?
    let identifiers: [String: String]
}

struct AuthorData: Sendable {
    let name: String
    let authority: String?
    let authorityURI: URL?
}

struct SubjectData: Sendable {
    let name: String
    let authority: String?
    let authorityURI: URL?
    let valueURI: URL?
}

struct DateData: Sendable {
    let dateString: String
    let encoding: String?
    let point: String?
    let qualifier: String?
}

// MARK: - Error Types
enum MODSImportError: Error {
    case missingUUID
    case invalidData
}
