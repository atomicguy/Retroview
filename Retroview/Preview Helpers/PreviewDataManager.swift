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
    private var modelContainer: ModelContainer?

    private init() {}

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
            isStoredInMemoryOnly: true  // Use in-memory storage for previews
        )

        let container = try ModelContainer(
            for: schema, configurations: [config])
        modelContainer = container
        return container
    }

    func reset() {
        modelContainer = nil
    }

    func populatePreviewData() async throws {
        reset()  // Clear existing container

        let container = try container()
        let context = container.mainContext

        // Create base entities
        let titles = createTitles(context: context)
        let authors = createAuthors(context: context)
        let subjects = createSubjects(context: context)
        let dates = createDates(context: context)

        // Create sample cards
        try await createSampleCards(
            context: context,
            titles: titles,
            authors: authors,
            subjects: subjects,
            dates: dates
        )

        try context.save()
    }
}
