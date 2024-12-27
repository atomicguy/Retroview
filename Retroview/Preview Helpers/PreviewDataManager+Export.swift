//
//  PreviewDataManager+Export.swift
//  Retroview
//
//  Created by Adam Schuster on 12/27/24.
//

import SwiftData
import SwiftUI

extension PreviewDataManager {
    func exportPreviewStore(from sourceContext: ModelContext) async throws
        -> String
    {
        guard
            let appSupport = FileManager.default.urls(
                for: .applicationSupportDirectory,
                in: .userDomainMask
            ).first
        else {
            throw ExportError.directoryAccessFailed
        }

        let previewDataDir = appSupport.appendingPathComponent("PreviewData")
        try? FileManager.default.createDirectory(
            at: previewDataDir,
            withIntermediateDirectories: true
        )

        let previewStoreURL = previewDataDir.appendingPathComponent(
            "preview.store")

        // Get the Favorites collection first
        let favoritesDescriptor = FetchDescriptor<
            CollectionSchemaV1.Collection
        >(
            predicate: ModelPredicates.Collection.favorites
        )

        guard let favorites = try sourceContext.fetch(favoritesDescriptor).first
        else {
            throw ExportError.exportFailed("Favorites collection not found")
        }

        let schema = sourceContext.container.schema
        let config = ModelConfiguration(
            url: previewStoreURL,
            allowsSave: true
        )

        let container = try ModelContainer(
            for: schema,
            configurations: [config]
        )
        let previewContext = container.mainContext

        // Copy all cards from Favorites
        for card in favorites.orderedCards {
            try await copyCard(card, to: previewContext)
        }

        try previewContext.save()

        let attributes = try FileManager.default.attributesOfItem(
            atPath: previewStoreURL.path)
        let fileSize = attributes[.size] as? Int64 ?? 0

        return """
            Preview store saved successfully!

            Location: \(previewStoreURL.path)
            Size: \(ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file))
            Cards: \(favorites.cards.count)
            """
    }

    private func copyCard(
        _ card: CardSchemaV1.StereoCard, to context: ModelContext
    ) async throws {
        let newCard = CardSchemaV1.StereoCard(
            uuid: card.uuid,
            imageFrontId: card.imageFrontId,
            imageBackId: card.imageBackId,
            cardColor: card.cardColor,
            colorOpacity: card.colorOpacity
        )

        // Copy stored image data
        @MainActor func copyImageData() {
            newCard.frontThumbnailData = card.frontThumbnailData
            newCard.frontStandardData = card.frontStandardData
            newCard.backThumbnailData = card.backThumbnailData
            newCard.backStandardData = card.backStandardData
        }

        // Ensure image data is copied on main actor
        await MainActor.run {
            copyImageData()
        }

        // Copy relationships and metadata as before...
        for title in card.titles {
            let newTitle = try await findOrCreateTitle(title.text, in: context)
            newCard.titles.append(newTitle)
        }

        if let titlePick = card.titlePick {
            newCard.titlePick = try await findOrCreateTitle(
                titlePick.text, in: context)
        }

        for author in card.authors {
            let newAuthor = try await findOrCreateAuthor(
                author.name, in: context)
            newCard.authors.append(newAuthor)
        }

        for subject in card.subjects {
            let newSubject = try await findOrCreateSubject(
                subject.name, in: context)
            newCard.subjects.append(newSubject)
        }

        for date in card.dates {
            let newDate = try await findOrCreateDate(date.text, in: context)
            newCard.dates.append(newDate)
        }

        for crop in card.crops {
            let newCrop = CropSchemaV1.Crop(
                x0: crop.x0, y0: crop.y0,
                x1: crop.x1, y1: crop.y1,
                score: crop.score,
                side: crop.side
            )
            newCrop.card = newCard
            newCard.crops.append(newCrop)
            context.insert(newCrop)
        }

        context.insert(newCard)
    }
    private func findOrCreateTitle(_ text: String, in context: ModelContext)
        async throws -> TitleSchemaV1.Title
    {
        let descriptor = FetchDescriptor<TitleSchemaV1.Title>(
            predicate: ModelPredicates.Title.matching(text))
        if let existing = try context.fetch(descriptor).first {
            return existing
        }
        let new = TitleSchemaV1.Title(text: text)
        context.insert(new)
        return new
    }

    private func findOrCreateAuthor(_ name: String, in context: ModelContext)
        async throws -> AuthorSchemaV1.Author
    {
        let descriptor = FetchDescriptor<AuthorSchemaV1.Author>(
            predicate: ModelPredicates.Author.withName(name))
        if let existing = try context.fetch(descriptor).first {
            return existing
        }
        let new = AuthorSchemaV1.Author(name: name)
        context.insert(new)
        return new
    }

    private func findOrCreateSubject(_ name: String, in context: ModelContext)
        async throws -> SubjectSchemaV1.Subject
    {
        let descriptor = FetchDescriptor<SubjectSchemaV1.Subject>(
            predicate: ModelPredicates.Subject.withName(name))
        if let existing = try context.fetch(descriptor).first {
            return existing
        }
        let new = SubjectSchemaV1.Subject(name: name)
        context.insert(new)
        return new
    }

    private func findOrCreateDate(_ text: String, in context: ModelContext)
        async throws -> DateSchemaV1.Date
    {
        let descriptor = FetchDescriptor<DateSchemaV1.Date>(
            predicate: ModelPredicates.Date.matching(text))
        if let existing = try context.fetch(descriptor).first {
            return existing
        }
        let new = DateSchemaV1.Date(text: text)
        context.insert(new)
        return new
    }
}

enum ExportError: LocalizedError {
    case directoryAccessFailed
    case exportFailed(String)

    var errorDescription: String? {
        switch self {
        case .directoryAccessFailed:
            "Could not access application support directory"
        case .exportFailed(let reason):
            "Export failed: \(reason)"
        }
    }
}
