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

        // Add and populate sample collections
        setupSampleCollections(in: context)

        do {
            try context.save()
        } catch {
            print("Failed to save preview context: \(error)")
        }
    }

    private func insertBaseEntities(in context: ModelContext) {
        func insert(_ entities: [some PersistentModel]) {
            entities.forEach { context.insert($0) }
        }

        insert(CardSchemaV1.StereoCard.sampleData)
        insert(TitleSchemaV1.Title.sampleData)
        insert(AuthorSchemaV1.Author.sampleData)
        insert(SubjectSchemaV1.Subject.sampleData)
        insert(DateSchemaV1.Date.sampleData)
    }

    private func setupRelationships(in _: ModelContext) {
        // Setup and verify relationships with detailed logging
        for (index, card) in CardSchemaV1.StereoCard.sampleData.enumerated() {
            setupCardRelationships(card: card, index: index)
        }

        // Verify setup
        verifySetup()
    }

    private func setupCardRelationships(card: CardSchemaV1.StereoCard, index: Int) {
        // Titles - Handle multiple titles per card
        let titles = getTitlesForCard(index: index)
        card.titles = titles
        card.titlePick = titles.first // Set first title as picked title

        // Authors
        if let author = getAuthorForCard(index: index) {
            card.authors = [author]
        }

        // Subjects - Using the new approach
        card.subjects = getSubjectsForCard(card: card)

        // Dates
        if let date = getDateForCard(index: index) {
            card.dates = [date]
        }

        // Crops
        setupCropsForCard(card: card, index: index)
    }

    private func getTitlesForCard(index: Int) -> [TitleSchemaV1.Title] {
        switch index {
        case 0: // First World's Fair card (lighthouse lens)
            return Array(TitleSchemaV1.Title.sampleData.prefix(2))
        case 1: // Second World's Fair card (Little-me-too)
            return Array(TitleSchemaV1.Title.sampleData[2 ... 3])
        case 2: // Cathedral Rocks card
            return Array(TitleSchemaV1.Title.sampleData[4 ... 5])
        case 3: // Yellowstone card
            return Array(TitleSchemaV1.Title.sampleData[6 ... 7])
        default:
            // For remaining cards, try to get a single title if available
            if index < TitleSchemaV1.Title.sampleData.count {
                return [TitleSchemaV1.Title.sampleData[index]]
            }
            return []
        }
    }

    private func getAuthorForCard(index: Int) -> AuthorSchemaV1.Author? {
        let authors = AuthorSchemaV1.Author.sampleData
        switch index {
        case 0, 1: // World's Fair cards by Kilburn
            return authors.first(where: { $0.name.contains("Kilburn") })
        case 2: // Cathedral Rocks by Littleton View Co.
            return authors.first(where: { $0.name == "Littleton View Co." })
        case 3: // Yellowstone by Unknown
            return authors.first(where: { $0.name == "Unknown" })
        case 4: // Young, R. Y.
            return authors.first(where: { $0.name == "Young, R. Y." })
        case 5: // Underwood & Underwood
            return authors.first(where: { $0.name == "Underwood & Underwood" })
        case 6: // Baker & Record
            return authors.first(where: { $0.name == "Baker & Record (Firm)" })
        default:
            return nil
        }
    }

    private func getSubjectsForCard(card: CardSchemaV1.StereoCard) -> [SubjectSchemaV1.Subject] {
        let subjects = SubjectSchemaV1.Subject.sampleData

        // Check if any of the card's titles contain World's Fair related terms
        let isWorldsFairCard = card.titles.contains { title in
            title.text.contains("World's") ||
                title.text.contains("Columbian Exposition") ||
                title.text.contains("World's Fair")
        }

        if isWorldsFairCard {
            return subjects.filter { subject in
                subject.name.contains("Chicago") ||
                    subject.name.contains("Illinois") ||
                    subject.name.contains("World's Columbian Exposition") ||
                    subject.name.contains("Exhibitions")
            }
        }

        // Rest of the existing cases...
        switch card.imageFrontId {
        case "G89F383_045F": // Cathedral Rocks
            return subjects.filter { subject in
                subject.name.contains("California")
            }
        case "G92F094_011F": // Yellowstone
            return subjects.filter { subject in
                subject.name.contains("Yellowstone") ||
                    subject.name.contains("Buttes") ||
                    subject.name.contains("Wyoming") ||
                    subject.name.contains("Rocks") ||
                    subject.name.contains("National parks")
            }
        // Handle Central Park cards
        case _ where card.titles.contains(where: { $0.text.contains("Central Park") }):
            return subjects.filter { subject in
                subject.name.contains("New York") ||
                    subject.name.contains("Manhattan") ||
                    subject.name.contains("Central Park") ||
                    subject.name.contains("Zoos") ||
                    subject.name.contains("Animals") ||
                    subject.name.contains("Parks")
            }
        default:
            return []
        }
    }

    private func getDateForCard(index: Int) -> DateSchemaV1.Date? {
        let dates = DateSchemaV1.Date.sampleData
        switch index {
        case 0, 1: // World's Fair cards
            return dates.first(where: { $0.text == "1893" })
        case 2, 3: // Cathedral Rocks and Yellowstone
            return dates.first(where: { $0.text == "Unknown" })
        case 4: // 1901 card
            return dates.first(where: { $0.text == "1901" })
        case 5: // 1902-1903 card
            return dates.first(where: { $0.text == "c1902-1903" })
        case 6: // 1865 card
            return dates.first(where: { $0.text == "1865" })
        default:
            return nil
        }
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

    private func setupSampleCollections(in context: ModelContext) {
        // Create sample collections
        let favorites = CollectionSchemaV1.Collection(name: "Favorites")
        let worldsFair = CollectionSchemaV1.Collection(name: "World's Fair")
        let newYork = CollectionSchemaV1.Collection(name: "New York City")
        let wonders = CollectionSchemaV1.Collection(name: "Natural Wonders")
        let parks = CollectionSchemaV1.Collection(name: "National Parks")

        for card in CardSchemaV1.StereoCard.sampleData {
            // Add first card to favorites
            if card == CardSchemaV1.StereoCard.sampleData.first {
                favorites.addCard(card)
            }

            // Add cards to appropriate collections based on subjects
            for subject in card.subjects {
                if subject.name.contains("World's Columbian Exposition") || subject.name.contains("Chicago") || subject.name.contains("Illinois") || subject.name.contains("Exhibitions") {
                    worldsFair.addCard(card)
                } else if subject.name.contains("New York") || subject.name.contains("Manhattan") || subject.name.contains("Central Park") || subject.name.contains("N.Y.") {
                    newYork.addCard(card)
                } else if subject.name.contains("California") || subject.name.contains("Rocks") {
                    wonders.addCard(card)
                } else if subject.name.contains("Yellowstone") ||
                    subject.name.contains("National parks")
                {
                    parks.addCard(card)
                    wonders.addCard(card) // Also add to Natural Wonders
                }
            }
        }

        // Insert collections
        [favorites, worldsFair, newYork, wonders, parks].forEach { context.insert($0) }
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

extension PreviewContainer {
    func previewCollection(named name: String) -> CollectionSchemaV1.Collection {
        let descriptor = FetchDescriptor<CollectionSchemaV1.Collection>(
            predicate: #Predicate<CollectionSchemaV1.Collection> { collection in
                collection.name == name
            }
        )

        return (try? modelContainer.mainContext.fetch(descriptor))?.first ??
            CollectionSchemaV1.Collection(name: "Preview Collection")
    }

    // Convenience var for commonly used collections
    var worldsFairCollection: CollectionSchemaV1.Collection {
        previewCollection(named: "World's Fair")
    }

    var naturalWondersCollection: CollectionSchemaV1.Collection {
        previewCollection(named: "Natural Wonders")
    }

    var newYorkCollection: CollectionSchemaV1.Collection {
        previewCollection(named: "New York City")
    }
}
