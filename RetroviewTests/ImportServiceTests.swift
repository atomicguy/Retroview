//
//  ImportServiceTests.swift
//  Retroview
//
//  Created by Adam Schuster on 11/28/24.
//

import SwiftData
import XCTest

@testable import Retroview

@MainActor
final class ImportServiceTests: XCTestCase {
    var modelContainer: ModelContainer!
    var modelContext: ModelContext!
    var importService: ImportService!

    override func setUpWithError() throws {
        let schema = Schema([
            CardSchemaV1.StereoCard.self,
            TitleSchemaV1.Title.self,
            AuthorSchemaV1.Author.self,
            SubjectSchemaV1.Subject.self,
            DateSchemaV1.Date.self,
            CropSchemaV1.Crop.self,
            CollectionSchemaV1.Collection.self,
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )

        modelContainer = try ModelContainer(
            for: schema,
            configurations: [modelConfiguration]
        )
        modelContext = ModelContext(modelContainer)
        importService = ImportService(modelContext: modelContext)
    }

    override func tearDownWithError() throws {
        modelContainer = nil
        modelContext = nil
        importService = nil
    }

    private func createTestCardJSON(
        uuid: String = "123e4567-e89b-12d3-a456-426614174000", // Valid UUID format
        titles: [String] = ["Test Title"],
        authors: [String] = ["Test Author"],
        subjects: [String] = ["Test Subject"],
        dates: [String] = ["1900"],
        imageIds: (front: String, back: String) = ("front-id", "back-id")
    ) -> StereoCardJSON {
        StereoCardJSON(
            uuid: uuid,
            titles: titles,
            subjects: subjects,
            authors: authors,
            dates: dates,
            imageIds: ImageIDs(front: imageIds.front, back: imageIds.back),
            left: CropData(
                x0: 0.1, y0: 0.1, x1: 0.9, y1: 0.9, score: 0.99, side: "left"
            ),
            right: CropData(
                x0: 0.1, y0: 0.1, x1: 0.9, y1: 0.9, score: 0.99, side: "right"
            )
        )
    }

    func testBasicCardImport() async throws {
        let cardJSON = createTestCardJSON()
        let jsonData = try JSONEncoder().encode(cardJSON)
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("test.json")
        try jsonData.write(to: tempURL)

        try await importService.importJSON(from: tempURL)

        let testUUID = UUID(uuidString: cardJSON.uuid)!
        let descriptor = FetchDescriptor<CardSchemaV1.StereoCard>(
            predicate: #Predicate<CardSchemaV1.StereoCard> {
                $0.uuid == testUUID
            }
        )

        let importedCards = try modelContext.fetch(descriptor)
        XCTAssertEqual(importedCards.count, 1)

        let importedCard = importedCards[0]
        XCTAssertEqual(importedCard.titles.first?.text, cardJSON.titles[0])
        XCTAssertEqual(importedCard.authors.first?.name, cardJSON.authors[0])
        XCTAssertEqual(importedCard.subjects.first?.name, cardJSON.subjects[0])
        XCTAssertEqual(importedCard.dates.first?.text, cardJSON.dates[0])
        XCTAssertEqual(importedCard.imageFrontId, cardJSON.imageIds.front)
        XCTAssertEqual(importedCard.imageBackId, cardJSON.imageIds.back)
    }

    func testMetadataDeduplication() async throws {
        let card1JSON = createTestCardJSON(
            uuid: "123e4567-e89b-12d3-a456-426614174001",
            titles: ["Title 1"],
            authors: ["Author 1"],
            subjects: ["Subject 1", "Shared Subject"],
            dates: ["1900"]
        )

        let card2JSON = createTestCardJSON(
            uuid: "123e4567-e89b-12d3-a456-426614174002",
            titles: ["Title 2"],
            authors: ["Author 1"],
            subjects: ["Subject 2", "Shared Subject"],
            dates: ["1900"]
        )

        for cardJSON in [card1JSON, card2JSON] {
            let jsonData = try JSONEncoder().encode(cardJSON)
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("\(cardJSON.uuid).json")
            try jsonData.write(to: tempURL)
            try await importService.importJSON(from: tempURL)
        }

        let authorDescriptor = FetchDescriptor<AuthorSchemaV1.Author>()
        let authors = try modelContext.fetch(authorDescriptor)
        XCTAssertEqual(authors.count, 1, "Should have only one author")

        let subjectDescriptor = FetchDescriptor<SubjectSchemaV1.Subject>()
        let subjects = try modelContext.fetch(subjectDescriptor)
        XCTAssertEqual(subjects.count, 3, "Should have three unique subjects")

        let dateDescriptor = FetchDescriptor<DateSchemaV1.Date>()
        let dates = try modelContext.fetch(dateDescriptor)
        XCTAssertEqual(dates.count, 1, "Should have only one date")
    }

    func testDuplicateCardPrevention() async throws {
        let cardJSON = createTestCardJSON()
        let jsonData = try JSONEncoder().encode(cardJSON)
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("test.json")
        try jsonData.write(to: tempURL)

        try await importService.importJSON(from: tempURL)
        try await importService.importJSON(from: tempURL)

        let descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
        let cards = try modelContext.fetch(descriptor)
        XCTAssertEqual(cards.count, 1, "Should prevent duplicate card import")
    }

    func testCardRelationships() async throws {
        let cardJSON = createTestCardJSON(
            uuid: "123e4567-e89b-12d3-a456-426614174003",
            titles: ["Title 1", "Title 2"],
            subjects: ["Subject 1", "Subject 2"]
        )

        let jsonData = try JSONEncoder().encode(cardJSON)
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("test.json")
        try jsonData.write(to: tempURL)

        try await importService.importJSON(from: tempURL)

        let descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
        let cards = try modelContext.fetch(descriptor)
        let card = try XCTUnwrap(cards.first)

        XCTAssertEqual(card.titles.count, 2, "Card should have two titles")
        XCTAssertEqual(card.subjects.count, 2, "Card should have two subjects")

        let title = try XCTUnwrap(card.titles.first)
        XCTAssertTrue(
            title.cards.contains(card),
            "Title should have a reference to the card"
        )

        let subject = try XCTUnwrap(card.subjects.first)
        XCTAssertTrue(
            subject.cards?.contains(card) ?? false,
            "Subject should have a reference to the card"
        )
    }
}
