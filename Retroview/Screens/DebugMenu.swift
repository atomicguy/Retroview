//
//  DebugMenu.swift
//  Retroview
//
//  Created by Adam Schuster on 11/29/24.
//

import SwiftData
import SwiftUI

#if DEBUG
    struct DebugMenu: View {
        @Environment(\.modelContext) private var modelContext

        var body: some View {
            Menu {
                Section {
                    Button(role: .destructive) {
                        RetroviewApp.clearAllData()
                    } label: {
                        Label("Clear All Data", systemImage: "trash")
                    }
                }

                Section {
                    Button {
                        loadSampleData()
                    } label: {
                        Label(
                            "Load Sample Data",
                            systemImage: "square.and.arrow.down")
                    }
                }
            } label: {
                Label("Debug", systemImage: "ladybug")
            }
        }

        private func loadSampleData() {
            // Insert base entities
            insertBaseEntities()

            // Setup relationships
            setupRelationships()

            // Add sample collections, skipping any that already exist
            for collection in CollectionSchemaV1.Collection.sampleData {
                let descriptor = FetchDescriptor<CollectionSchemaV1.Collection>(
                    predicate: #Predicate<CollectionSchemaV1.Collection> {
                        collection in
                        collection.name == collection.name
                    }
                )

                // Only insert if collection doesn't exist
                if let existingCollections = try? modelContext.fetch(
                    descriptor),
                    existingCollections.isEmpty
                {
                    modelContext.insert(collection)
                }
            }

            do {
                try modelContext.save()
            } catch {
                print("Failed to save sample data: \(error)")
            }
        }

        private func insertBaseEntities() {
            func insert<T: PersistentModel>(_ entities: [T]) {
                entities.forEach { modelContext.insert($0) }
            }

            insert(CardSchemaV1.StereoCard.sampleData)
            insert(TitleSchemaV1.Title.sampleData)
            insert(AuthorSchemaV1.Author.sampleData)
            insert(SubjectSchemaV1.Subject.sampleData)
            insert(DateSchemaV1.Date.sampleData)
        }

        private func setupRelationships() {
            // Setup relationships with detailed logging
            for (index, card) in CardSchemaV1.StereoCard.sampleData.enumerated()
            {
                setupCardRelationships(card: card, index: index)
            }
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

        private func getSubjectsForCard(index: Int) -> [SubjectSchemaV1.Subject]
        {
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

        private func setupCropsForCard(
            card: CardSchemaV1.StereoCard, index: Int
        ) {
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
    }
#endif
