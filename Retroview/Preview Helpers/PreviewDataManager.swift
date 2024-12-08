//
//  PreviewDataManager.swift
//  Retroview
//
//  Created by Adam Schuster on 12/7/24.
//

import SwiftData
import SwiftUI

@MainActor
final class PreviewDataManager {
    static let shared = PreviewDataManager()
    
    private let previewStoreURL: URL
    private var modelContainer: ModelContainer?
    
    private init() {
        let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let previewDir = appSupport.appendingPathComponent("PreviewData", isDirectory: true)
        try? FileManager.default.createDirectory(at: previewDir, withIntermediateDirectories: true)
        previewStoreURL = previewDir.appendingPathComponent("preview.store")
    }
    
    func container() throws -> ModelContainer {
        if let existing = modelContainer {
            return existing
        }
        
        let schema = Schema([
            CardSchemaV1.StereoCard.self,
            TitleSchemaV1.Title.self,
            AuthorSchemaV1.Author.self,
            SubjectSchemaV1.Subject.self,
            DateSchemaV1.Date.self,
            CropSchemaV1.Crop.self,
            CollectionSchemaV1.Collection.self,
        ])
        
        let config = ModelConfiguration(
            schema: schema,
            url: previewStoreURL
        )
        
        let container = try ModelContainer(for: schema, configurations: [config])
        modelContainer = container
        return container
    }
    
    func populatePreviewData() async throws {
        let container = try container()
        let context = container.mainContext
        
        // Check if we already have data
        let cardDescriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
        let existingCards = try context.fetch(cardDescriptor)
        
        guard existingCards.isEmpty else {
            print("Preview data already exists")
            return
        }
        
        // Create base entities
        let titles = createTitles(context: context)
        let authors = createAuthors(context: context)
        let subjects = createSubjects(context: context)
        let dates = createDates(context: context)
        
        // Create sample cards with relationships
        try await createSampleCards(
            context: context,
            titles: titles,
            authors: authors,
            subjects: subjects,
            dates: dates
        )
        
        // Create collections
        createCollections(context: context)
        
        try context.save()
    }
    
    func reset() throws {
        modelContainer = nil
        try FileManager.default.removeItem(at: previewStoreURL)
    }
}

// MARK: - Sample Data Creation
private extension PreviewDataManager {
    func createTitles(context: ModelContext) -> [TitleSchemaV1.Title] {
        let titles = [
            "Mirror view of Cathedral Rocks, 2.660 ft. Cal.",
            "Soda Butte, Yellowstone National Park.",
            "Playful as kittens - sea lions, Central Park, N.Y., U.S.A.",
            "The great Ferris Wheel, Midway Plaisance, Columbian Exposition."
        ].map { TitleSchemaV1.Title(text: $0) }
        
        titles.forEach { context.insert($0) }
        return titles
    }
    
    func createAuthors(context: ModelContext) -> [AuthorSchemaV1.Author] {
        let authors = [
            "Kilburn, B. W. (Benjamin West) (1827-1909)",
            "Littleton View Co.",
            "Underwood & Underwood",
            "Baker & Record (Firm)"
        ].map { AuthorSchemaV1.Author(name: $0) }
        
        authors.forEach { context.insert($0) }
        return authors
    }
    
    func createSubjects(context: ModelContext) -> [SubjectSchemaV1.Subject] {
        let subjects = [
            "California",
            "Yellowstone National Park",
            "Central Park (New York, N.Y.)",
            "World's Columbian Exposition (1893 : Chicago, Ill.)"
        ].map { SubjectSchemaV1.Subject(name: $0) }
        
        subjects.forEach { context.insert($0) }
        return subjects
    }
    
    func createDates(context: ModelContext) -> [DateSchemaV1.Date] {
        let dates = [
            "1893",
            "1901",
            "c1902-1903",
            "1865"
        ].map { DateSchemaV1.Date(text: $0) }
        
        dates.forEach { context.insert($0) }
        return dates
    }
    
    func createSampleCards(
        context: ModelContext,
        titles: [TitleSchemaV1.Title],
        authors: [AuthorSchemaV1.Author],
        subjects: [SubjectSchemaV1.Subject],
        dates: [DateSchemaV1.Date]
    ) async throws {
        let cardData = [
            (
                uuid: "f886fee0-c53b-012f-de2a-58d385a7bc34",
                front: "G90F186_140F",
                back: "G90F186_140B",
                titleIndex: 0,
                authorIndex: 0,
                subjectIndex: 0,
                dateIndex: 0
            ),
            (
                uuid: "f3489f60-c53b-012f-42ca-58d385a7bc34",
                front: "G90F186_128F",
                back: "G90F186_128B",
                titleIndex: 1,
                authorIndex: 1,
                subjectIndex: 1,
                dateIndex: 1
            ),
        ]
        
        for data in cardData {
            let card = CardSchemaV1.StereoCard(
                uuid: data.uuid,
                imageFrontId: data.front,
                imageBackId: data.back
            )
            
            // Set relationships
            card.titles = [titles[data.titleIndex]]
            card.titlePick = titles[data.titleIndex]
            card.authors = [authors[data.authorIndex]]
            card.subjects = [subjects[data.subjectIndex]]
            card.dates = [dates[data.dateIndex]]
            
            // Download images
            try? await card.downloadImage(forSide: "front")
            try? await card.downloadImage(forSide: "back")
            
            context.insert(card)
        }
    }
    
    func createCollections(context: ModelContext) {
        let collections = [
            "Favorites",
            "World's Fair",
            "New York City",
            "Natural Wonders"
        ].map { CollectionSchemaV1.Collection(name: $0) }
        
        collections.forEach { context.insert($0) }
        
        // Fetch all cards and add them to relevant collections
        let descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
        guard let cards = try? context.fetch(descriptor) else { return }
        
        for card in cards {
            let subjectNames = card.subjects.map { $0.name }
            
            if subjectNames.contains("World's Columbian Exposition (1893 : Chicago, Ill.)") {
                collections[1].addCard(card)
            }
            if subjectNames.contains("Central Park (New York, N.Y.)") {
                collections[2].addCard(card)
            }
            if subjectNames.contains("California") || subjectNames.contains("Yellowstone National Park") {
                collections[3].addCard(card)
            }
        }
    }
}

// MARK: - Preview Support
struct PreviewContainerModifier: ViewModifier {
    let populate: Bool
    
    init(populate: Bool = true) {
        self.populate = populate
    }
    
    func body(content: Content) -> some View {
        content
            .task {
                if populate {
                    do {
                        try await PreviewDataManager.shared.populatePreviewData()
                    } catch {
                        print("Failed to populate preview data: \(error)")
                    }
                }
            }
            .modelContainer(try! PreviewDataManager.shared.container())
    }
}

extension View {
    func withPreviewData(populate: Bool = true) -> some View {
        modifier(PreviewContainerModifier(populate: populate))
    }
}
