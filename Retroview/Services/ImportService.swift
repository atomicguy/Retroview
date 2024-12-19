//
//  ImportService.swift
//  Retroview
//
//  Created by Adam Schuster on 11/27/24.
//

import CoreGraphics
import Foundation
import SwiftData

@MainActor
class ImportService {
    let modelContext: ModelContext
    private let batchSize: Int
    
    init(
        modelContext: ModelContext,
        batchSize: Int = 50
    ) {
        self.modelContext = modelContext
        self.batchSize = batchSize
    }
    
    func importJSON(from url: URL) async throws {
        print("\n📄 Processing file: \(url.lastPathComponent)")
        
        do {
            let data = try Data(contentsOf: url)
            
            // Try parsing as simplified JSON first
            if let cardData = try? JSONDecoder().decode(StereoCardJSON.self, from: data) {
                let uuid = UUID(uuidString: cardData.uuid) ?? UUID()
                
                // Check if card already exists
                if try cardExists(uuid: uuid) {
                    print("⏭️ Skipping existing card: \(cardData.uuid)")
                    return
                }
                
                try await importCard(from: cardData)
                try modelContext.save()
                print("✅ Successfully imported: \(url.lastPathComponent)")
                return
            }
            
            // If simplified JSON parsing fails, try MODS format
            print("⚠️ Trying MODS format for: \(url.lastPathComponent)")
            do {
                let cardData = try MODSParsingService.convertMODSToStereoCard(data, fileName: url.lastPathComponent)
                let uuid = UUID(uuidString: cardData.uuid) ?? UUID()
                
                // Check if card already exists
                if try cardExists(uuid: uuid) {
                    print("⏭️ Skipping existing card: \(cardData.uuid)")
                    return
                }
                
                try await importCard(from: cardData)
                try modelContext.save()
                print("✅ Successfully imported MODS data from: \(url.lastPathComponent)")
            } catch {
                ImportLogger.log(.error, "Failed to import MODS data: \(error.localizedDescription)", file: url.lastPathComponent)
                return
            }
        } catch {
            ImportLogger.log(.error, "Failed to read file: \(error.localizedDescription)", file: url.lastPathComponent)
            return
        }
    }

    func importCard(from cardData: StereoCardJSON) async throws {
        let uuid = UUID(uuidString: cardData.uuid) ?? UUID()
        
        // Skip if card already exists
        if try cardExists(uuid: uuid) {
            print("Card \(cardData.uuid) already exists, skipping import")
            return
        }
        
        // Create or get existing entities
        let titles = try await getTitles(from: cardData.titles)
        let authors = try await getAuthors(from: cardData.authors)
        let subjects = try await getSubjects(from: cardData.subjects)
        let dates = try await getDates(from: cardData.dates)
        
        // Create crops
        let leftCrop = CropSchemaV1.Crop(
            x0: cardData.left.x0,
            y0: cardData.left.y0,
            x1: cardData.left.x1,
            y1: cardData.right.y1,
            score: cardData.left.score,
            side: cardData.left.side
        )
        
        let rightCrop = CropSchemaV1.Crop(
            x0: cardData.right.x0,
            y0: cardData.right.y0,
            x1: cardData.right.x1,
            y1: cardData.right.y1,
            score: cardData.right.score,
            side: cardData.right.side
        )
        
        // Create new card
        let card = CardSchemaV1.StereoCard(
            uuid: cardData.uuid,
            imageFrontId: cardData.imageIds.front,
            imageBackId: cardData.imageIds.back,
            titles: titles,
            authors: authors,
            subjects: subjects,
            dates: dates,
            crops: [leftCrop, rightCrop]
        )
        
        // Set the first title as the picked title
        card.titlePick = titles.first
        
        // Preload thumbnail before inserting
        await preloadThumbnail(for: card)
        
        modelContext.insert(card)
    }
    
    private func preloadThumbnail(for card: CardSchemaV1.StereoCard) async {
        // Only attempt front thumbnail
        guard let frontId = card.imageFrontId else { return }
        
        do {
            let urlString = "https://iiif-prod.nypl.org/index.php?id=\(frontId)&t=\(ImageQuality.thumbnail.rawValue)"
            guard let url = URL(string: urlString) else { return }
            
            let (data, _) = try await URLSession.shared.data(from: url)
            
            // Store only the thumbnail data
            card.frontThumbnailData = data
            
            ImportLogger.log(.info, "Successfully loaded thumbnail for card: \(card.uuid)")
        } catch {
            ImportLogger.log(.warning, "Failed to load thumbnail for \(card.uuid): \(error.localizedDescription)")
            // Continue import even if thumbnail load fails
        }
    }
    
    private func getTitles(from titleStrings: [String]) async throws -> [TitleSchemaV1.Title] {
        try await withThrowingTaskGroup(of: TitleSchemaV1.Title.self) { group in
            for titleString in titleStrings {
                group.addTask {
                    try await self.getOrCreateTitle(matching: titleString)
                }
            }
            
            var titles = [TitleSchemaV1.Title]()
            for try await title in group {
                titles.append(title)
            }
            return titles
        }
    }
    
    private func getAuthors(from authorStrings: [String]) async throws -> [AuthorSchemaV1.Author] {
        try await withThrowingTaskGroup(of: AuthorSchemaV1.Author.self) { group in
            for authorString in authorStrings {
                group.addTask {
                    try await self.getOrCreateAuthor(matching: authorString)
                }
            }
            
            var authors = [AuthorSchemaV1.Author]()
            for try await author in group {
                authors.append(author)
            }
            return authors
        }
    }
    
    private func getSubjects(from subjectStrings: [String]) async throws -> [SubjectSchemaV1.Subject] {
        try await withThrowingTaskGroup(of: SubjectSchemaV1.Subject.self) { group in
            for subjectString in subjectStrings {
                group.addTask {
                    try await self.getOrCreateSubject(matching: subjectString)
                }
            }
            
            var subjects = [SubjectSchemaV1.Subject]()
            for try await subject in group {
                subjects.append(subject)
            }
            return subjects
        }
    }
    
    private func getDates(from dateStrings: [String]) async throws -> [DateSchemaV1.Date] {
        try await withThrowingTaskGroup(of: DateSchemaV1.Date.self) { group in
            for dateString in dateStrings {
                group.addTask {
                    try await self.getOrCreateDate(matching: dateString)
                }
            }
            
            var dates = [DateSchemaV1.Date]()
            for try await date in group {
                dates.append(date)
            }
            return dates
        }
    }
    
    private func getOrCreateTitle(matching text: String) async throws -> TitleSchemaV1.Title {
        let descriptor = FetchDescriptor<TitleSchemaV1.Title>(
            predicate: #Predicate<TitleSchemaV1.Title> { title in
                title.text == text
            }
        )
        
        if let existing = try modelContext.fetch(descriptor).first {
            return existing
        }
        
        let newTitle = TitleSchemaV1.Title(text: text)
        modelContext.insert(newTitle)
        return newTitle
    }
    
    private func getOrCreateAuthor(matching name: String) async throws -> AuthorSchemaV1.Author {
        let descriptor = FetchDescriptor<AuthorSchemaV1.Author>(
            predicate: #Predicate<AuthorSchemaV1.Author> { author in
                author.name == name
            }
        )
        
        if let existing = try modelContext.fetch(descriptor).first {
            return existing
        }
        
        let newAuthor = AuthorSchemaV1.Author(name: name)
        modelContext.insert(newAuthor)
        return newAuthor
    }
    
    private func getOrCreateSubject(matching name: String) async throws -> SubjectSchemaV1.Subject {
        let descriptor = FetchDescriptor<SubjectSchemaV1.Subject>(
            predicate: #Predicate<SubjectSchemaV1.Subject> { subject in
                subject.name == name
            }
        )
        
        if let existing = try modelContext.fetch(descriptor).first {
            return existing
        }
        
        let newSubject = SubjectSchemaV1.Subject(name: name)
        modelContext.insert(newSubject)
        return newSubject
    }
    
    private func getOrCreateDate(matching text: String) async throws -> DateSchemaV1.Date {
        let descriptor = FetchDescriptor<DateSchemaV1.Date>(
            predicate: #Predicate<DateSchemaV1.Date> { date in
                date.text == text
            }
        )
        
        if let existing = try modelContext.fetch(descriptor).first {
            return existing
        }
        
        let newDate = DateSchemaV1.Date(text: text)
        modelContext.insert(newDate)
        return newDate
    }
}
