//
//  StereoCard.swift
//  Retroview
//
//  Created by Adam Schuster on 4/6/24.
//

import Foundation
import SwiftData
import SwiftUI

enum CardSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version = .init(0, 1, 0)

    static var models: [any PersistentModel.Type] {
        [
            CardSchemaV1.StereoCard.self,
            TitleSchemaV1.Title.self,
            AuthorSchemaV1.Author.self,
            SubjectSchemaV1.Subject.self,
            DateSchemaV1.Date.self,
        ]
    }

    @Model
    class StereoCard {
        @Attribute(.unique) var uuid: UUID
        var imageFrontId: String?
        var imageBackId: String?
        var cardColor: String = "#F5E6D3"
        var colorOpacity: Double

        // Separate storage for different image sizes
        @Attribute(.externalStorage) var frontThumbnailData: Data?
        @Attribute(.externalStorage) var frontStandardData: Data?
        @Attribute(.externalStorage) var backThumbnailData: Data?
        @Attribute(.externalStorage) var backStandardData: Data?

        @Relationship(deleteRule: .cascade, inverse: \TitleSchemaV1.Title.cards)
        var titles = [TitleSchemaV1.Title]()

        @Relationship(deleteRule: .nullify, inverse: \TitleSchemaV1.Title.picks)
        var titlePick: TitleSchemaV1.Title?

        @Relationship(inverse: \AuthorSchemaV1.Author.cards)
        var authors = [AuthorSchemaV1.Author]()

        @Relationship(inverse: \SubjectSchemaV1.Subject.cards)
        var subjects = [SubjectSchemaV1.Subject]()

        @Relationship(inverse: \DateSchemaV1.Date.cards)
        var dates = [DateSchemaV1.Date]()

        @Relationship(deleteRule: .cascade)
        var crops: [CropSchemaV1.Crop] = []

        var leftCrop: CropSchemaV1.Crop? {
            get { crops.first { $0.side == CropSchemaV1.Side.left.rawValue } }
            set {
                if let existingIndex = crops.firstIndex(where: {
                    $0.side == CropSchemaV1.Side.left.rawValue
                }) {
                    crops.remove(at: existingIndex)
                }
                if let newCrop = newValue {
                    crops.append(newCrop)
                    newCrop.card = self
                }
            }
        }

        var rightCrop: CropSchemaV1.Crop? {
            get { crops.first { $0.side == CropSchemaV1.Side.right.rawValue } }
            set {
                if let existingIndex = crops.firstIndex(where: {
                    $0.side == CropSchemaV1.Side.right.rawValue
                }) {
                    crops.remove(at: existingIndex)
                }
                if let newCrop = newValue {
                    crops.append(newCrop)
                    newCrop.card = self
                }
            }
        }

        var color: Color {
            get {
                (Color(hex: cardColor) ?? Color(hex: "#F5E6D3")!)
                    .opacity(colorOpacity)
            }
            set {
                cardColor = newValue.toHex() ?? "#F5E6D3"
                colorOpacity = 0.15
            }
        }

        init(
            uuid: String,
            imageFrontId: String? = nil,
            imageBackId: String? = nil,
            cardColor: String = "#F5E6D3",
            colorOpacity: Double = 0.15,
            titles: [TitleSchemaV1.Title] = [],
            authors: [AuthorSchemaV1.Author] = [],
            subjects: [SubjectSchemaV1.Subject] = [],
            dates: [DateSchemaV1.Date] = [],
            crops: [CropSchemaV1.Crop] = []
        ) {
            if let parsedUUID = UUID(uuidString: uuid.lowercased()) {
                self.uuid = parsedUUID
            } else {
                print(
                    "⚠️ Warning: Invalid UUID provided: \(uuid), generating new UUID"
                )
                self.uuid = UUID()
            }
            self.imageFrontId = imageFrontId
            self.imageBackId = imageBackId
            self.cardColor = cardColor
            self.colorOpacity = colorOpacity
            self.titles = titles
            self.authors = authors
            self.subjects = subjects
            self.dates = dates
            self.crops = crops

            // Initialize image data properties as nil
            self.frontThumbnailData = nil
            self.frontStandardData = nil
            self.backThumbnailData = nil
            self.backStandardData = nil
        }

        // Main interface that views will use - @MainActor since it's called from SwiftUI
        @MainActor
        func loadImage(side: CardSide, quality: ImageQuality = .standard)
            async throws -> CGImage?
        {
            // Get image ID and cached data on main thread
            let imageId = side == .front ? imageFrontId : imageBackId
            let cachedData = getCachedData(for: side, quality: quality)

            // Dispatch all heavy work to background
            return try await Task.detached {
                // If we have cached data, create image from that
                if let data = cachedData {
                    return Self.createCGImage(from: data)
                }

                // Otherwise fetch and create
                let data = try await Self.fetchImageData(
                    id: imageId, quality: quality)
                let image = Self.createCGImage(from: data)

                // Store in cache back on main actor
                await MainActor.run {
                    self.storeImageData(data, for: side, quality: quality)
                }

                return image
            }.value
        }

        // Synchronous cache check on main actor
        @MainActor
        private func getCachedData(for side: CardSide, quality: ImageQuality)
            -> Data?
        {
            switch (side, quality) {
            case (.front, .thumbnail): return frontThumbnailData
            case (.front, _): return frontStandardData
            case (.back, .thumbnail): return backThumbnailData
            case (.back, _): return backStandardData
            }
        }

        // Store data on main actor
        @MainActor
        private func storeImageData(
            _ data: Data, for side: CardSide, quality: ImageQuality
        ) {
            switch (side, quality) {
            case (.front, .thumbnail):
                frontThumbnailData = data
            case (.front, _):
                frontStandardData = data
            case (.back, .thumbnail):
                backThumbnailData = data
            case (.back, _):
                backStandardData = data
            }
        }

        // Background network fetch
        private static func fetchImageData(id: String?, quality: ImageQuality)
            async throws -> Data
        {
            guard let id = id else {
                throw ImageError.noImageId
            }

            let urlString =
                "https://iiif-prod.nypl.org/index.php?id=\(id)&t=\(quality.rawValue)"
            guard let url = URL(string: urlString) else {
                throw ImageError.invalidURL
            }

            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        }

        // Background image creation
        private static func createCGImage(from data: Data) -> CGImage? {
            guard let provider = CGDataProvider(data: data as CFData),
                let image = CGImage(
                    jpegDataProviderSource: provider,
                    decode: nil,
                    shouldInterpolate: true,
                    intent: .defaultIntent
                )
            else {
                return nil
            }
            return image
        }
    }
}

// MARK: - Transferable Conformance
extension CardSchemaV1.StereoCard: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation<CardSchemaV1.StereoCard, String>(exporting: {
            card in
            card.uuid.uuidString
        })
    }
}

enum ImageError: Error {
    case noImageId
    case invalidURL
    case invalidImageData

    var localizedDescription: String {
        switch self {
        case .noImageId:
            "No image ID available"
        case .invalidURL:
            "Invalid image URL"
        case .invalidImageData:
            "Invalid image data"
        }
    }
}
