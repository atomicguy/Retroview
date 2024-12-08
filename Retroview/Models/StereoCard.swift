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
        @Attribute(.unique)
        var uuid: UUID
        @Attribute(.externalStorage)
        var imageFront: Data?
        var imageFrontId: String?
        @Attribute(.externalStorage)
        var imageBack: Data?
        var imageBackId: String?
        var cardColor: String = "#F5E6D3"
        var colorOpacity: Double

        @Relationship(inverse: \TitleSchemaV1.Title.cards)
        var titles = [TitleSchemaV1.Title]()
        @Relationship(inverse: \TitleSchemaV1.Title.picks)
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
                colorOpacity = 0.15  // Default opacity when setting new color
            }
        }

        enum CodingKeys: String, CodingKey {
            case uuid, imageFrontId, imageBackId, cardColor, colorOpacity
        }

        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            uuid = try container.decode(UUID.self, forKey: .uuid)
            imageFrontId = try container.decodeIfPresent(
                String.self, forKey: .imageFrontId
            )
            imageBackId = try container.decodeIfPresent(
                String.self, forKey: .imageBackId
            )
            cardColor =
                try container.decodeIfPresent(
                    String.self, forKey: .cardColor
                ) ?? "#F5E6D3"
            colorOpacity =
                try container.decodeIfPresent(
                    Double.self, forKey: .colorOpacity
                ) ?? 0.15
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(uuid, forKey: .uuid)
            try container.encodeIfPresent(imageFrontId, forKey: .imageFrontId)
            try container.encodeIfPresent(imageBackId, forKey: .imageBackId)
            try container.encode(cardColor, forKey: .cardColor)
            try container.encode(colorOpacity, forKey: .colorOpacity)
        }

        init(
            uuid: String,
            imageFront: Data? = nil,
            imageFrontId: String? = "",
            imageBack: Data? = nil,
            imageBackId: String? = "",
            cardColor: String = "#F5E6D3",
            colorOpacity: Double = 0.15,
            titles: [TitleSchemaV1.Title] = [],
            authors: [AuthorSchemaV1.Author] = [],
            subjects: [SubjectSchemaV1.Subject] = [],
            dates: [DateSchemaV1.Date] = [],
            crops: [CropSchemaV1.Crop] = []
        ) {
            self.uuid = UUID(uuidString: uuid) ?? UUID()
            self.imageFront = imageFront
            self.imageFrontId = imageFrontId
            self.imageBack = imageBack
            self.imageBackId = imageBackId
            self.cardColor = cardColor
            self.colorOpacity = colorOpacity
            self.titles = titles
            self.authors = authors
            self.subjects = subjects
            self.dates = dates
            self.crops = crops
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
