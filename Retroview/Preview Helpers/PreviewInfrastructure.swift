//
//  PreviewInfrastructure.swift
//  Retroview
//
//  Created by Adam Schuster on 11/27/24.
//

import SwiftData
import SwiftUI

// MARK: - Preview Infrastructure

@MainActor
final class PreviewContainer {
    static let shared = PreviewContainer()

    let modelContainer: ModelContainer

    private init() {
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

        do {
            modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            setupSampleData()
        } catch {
            fatalError("Could not create preview ModelContainer: \(error)")
        }
    }

    // MARK: - Sample Data Setup

    private func setupSampleData() {
        let context = modelContainer.mainContext

        // Insert base entities
        insertBaseEntities(in: context)

        // Setup relationships
        setupRelationships(in: context)

        // Add sample collections
        CollectionSchemaV1.Collection.sampleData.forEach { context.insert($0) }

        do {
            try context.save()
        } catch {
            print("Failed to save preview context: \(error)")
        }
    }

    private func insertBaseEntities(in context: ModelContext) {
        func insert<T: PersistentModel>(_ entities: [T]) {
            entities.forEach { context.insert($0) }
        }

        insert(CardSchemaV1.StereoCard.sampleData)
        insert(TitleSchemaV1.Title.sampleData)
        insert(AuthorSchemaV1.Author.sampleData)
        insert(SubjectSchemaV1.Subject.sampleData)
        insert(DateSchemaV1.Date.sampleData)
    }

    private func setupRelationships(in context: ModelContext) {
        // Setup and verify relationships with detailed logging
        for (index, card) in CardSchemaV1.StereoCard.sampleData.enumerated() {
            setupCardRelationships(card: card, index: index)
        }

        // Verify setup
        verifySetup()
    }

    private func setupCardRelationships(
        card: CardSchemaV1.StereoCard, index: Int
    ) {
        // Titles
        if let title = getTitleForCard(index: index) {
            card.titles = [title]
            card.titlePick = title
        }

        // Authors
        if let author = getAuthorForCard(index: index) {
            card.authors = [author]
        }

        // Subjects
        card.subjects = getSubjectsForCard(index: index)

        // Dates
        if let date = getDateForCard(index: index) {
            card.dates = [date]
        }

        // Crops
        setupCropsForCard(card: card, index: index)
    }

    private func getTitleForCard(index: Int) -> TitleSchemaV1.Title? {
        guard index < TitleSchemaV1.Title.sampleData.count else {
            print("Warning: No title available for card index \(index)")
            return nil
        }
        return TitleSchemaV1.Title.sampleData[index]
    }

    private func getAuthorForCard(index: Int) -> AuthorSchemaV1.Author? {
        guard index < AuthorSchemaV1.Author.sampleData.count else {
            print("Warning: No author available for card index \(index)")
            return nil
        }
        return AuthorSchemaV1.Author.sampleData[index]
    }

    private func getSubjectsForCard(index: Int) -> [SubjectSchemaV1.Subject] {
        // Return appropriate subjects based on card index
        switch index {
        case 0:
            return Array(SubjectSchemaV1.Subject.sampleData.prefix(4))
        case 1:
            return Array(SubjectSchemaV1.Subject.sampleData.prefix(4))
        case 2:
            return Array(SubjectSchemaV1.Subject.sampleData[7...13])
        case 3:
            return Array(SubjectSchemaV1.Subject.sampleData[14...17])
        default:
            return []
        }
    }

    private func getDateForCard(index: Int) -> DateSchemaV1.Date? {
        guard index < DateSchemaV1.Date.sampleData.count else {
            print("Warning: No date available for card index \(index)")
            return nil
        }
        return DateSchemaV1.Date.sampleData[index]
    }

    private func setupCropsForCard(card: CardSchemaV1.StereoCard, index: Int) {
        let cropIndex = index * 2
        guard cropIndex + 1 < CropSchemaV1.Crop.sampleData.count else {
            print("Warning: Not enough crops for card index \(index)")
            return
        }

        let leftCrop = CropSchemaV1.Crop.sampleData[cropIndex]
        let rightCrop = CropSchemaV1.Crop.sampleData[cropIndex + 1]

        card.leftCrop = leftCrop
        card.rightCrop = rightCrop
        leftCrop.card = card
        rightCrop.card = card
    }

    private func verifySetup() {
        for (index, card) in CardSchemaV1.StereoCard.sampleData.enumerated() {
            print("Verifying card \(index):")
            print("- Title: \(card.titlePick?.text ?? "No title")")
            print(
                "- Authors: \(card.authors.map(\.name).joined(separator: ", "))"
            )
            print("- Subjects: \(card.subjects.count) subjects")
            print(
                "- Has crops: left=\(card.leftCrop != nil), right=\(card.rightCrop != nil)"
            )
        }
    }

    // MARK: - Convenience Accessors

    var previewCard: CardSchemaV1.StereoCard {
        CardSchemaV1.StereoCard.sampleData[0]
    }

    var previewCards: [CardSchemaV1.StereoCard] {
        CardSchemaV1.StereoCard.sampleData
    }
}

// MARK: - Preview View Modifiers

extension View {
    func withPreviewContainer() -> some View {
        modelContainer(PreviewContainer.shared.modelContainer)
    }
}

// MARK: - Preview Containers

struct CardPreviewContainer<Content: View>: View {
    let content: (CardSchemaV1.StereoCard) -> Content

    init(@ViewBuilder content: @escaping (CardSchemaV1.StereoCard) -> Content) {
        self.content = content
    }

    var body: some View {
        content(PreviewContainer.shared.previewCard)
            .withPreviewContainer()
    }
}

struct CardsPreviewContainer<Content: View>: View {
    let content: ([CardSchemaV1.StereoCard]) -> Content

    init(@ViewBuilder content: @escaping ([CardSchemaV1.StereoCard]) -> Content) {
        self.content = content
    }

    var body: some View {
        content(PreviewContainer.shared.previewCards)
            .withPreviewContainer()
    }
}

struct AsyncPreviewContainer<Content: View>: View {
    let content: () async -> Content
    @State private var loadedView: Content?

    init(@ViewBuilder content: @escaping () async -> Content) {
        self.content = content
    }

    var body: some View {
        Group {
            if let loadedView {
                loadedView.withPreviewContainer()
            } else {
                ProgressView("Loading preview...")
                    .task {
                        loadedView = await content()
                    }
            }
        }
    }
}
