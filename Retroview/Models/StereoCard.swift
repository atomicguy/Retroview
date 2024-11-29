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
            CardSchemaV1.StereoCard.self, TitleSchemaV1.Title.self,
            AuthorSchemaV1.Author.self, SubjectSchemaV1.Subject.self,
            DateSchemaV1.Date.self,
        ]
    }

    static var imageURLTemplate =
        "https://iiif-prod.nypl.org/index.php?id=%@&t=w"

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

        // Store all crops in a single array
        @Relationship(deleteRule: .cascade)
        var crops: [CropSchemaV1.Crop] = []

        // Computed properties for accessing left and right crops
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

        // Helper for converting stored hex to Color
        var color: Color {
            get {
                (Color(hex: cardColor) ?? Color(hex: "#F5E6D3")!)
                    .opacity(colorOpacity)
            }
            set {
                cardColor = newValue.toHex() ?? "#F5E6D3"
                colorOpacity = 0.15 // Default opacity when setting new color
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

        func imageUrl(forSide side: String) -> URL? {
            let baseUrl = "https://iiif-prod.nypl.org/index.php?id="
            let sizeSuffix = "&t=w"
            var imageName = imageFrontId
            if side == "back" {
                imageName = imageBackId
            }
            let imageUrl = baseUrl + (imageName ?? "unknown") + sizeSuffix
            return URL(string: imageUrl)
        }

        // Function to download image and store it as external storage
        func downloadImage(
            forSide side: String,
            completion: @escaping (Result<Void, Error>) -> Void
        ) {
            guard let url = imageUrl(forSide: side) else {
                let error = NSError(
                    domain: "", code: 0,
                    userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]
                )
                print("Invalid URL for side: \(side)")
                completion(.failure(error))
                return
            }

            print("Starting download for \(side) image from URL: \(url)")

            let task = URLSession.shared.dataTask(with: url) {
                data, response, error in
                if let error = error {
                    print("Download error for \(side): \(error)")
                    completion(.failure(error))
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    print(
                        "HTTP Status code for \(side): \(httpResponse.statusCode)"
                    )
                }

                guard let data = data else {
                    let error = NSError(
                        domain: "", code: 0,
                        userInfo: [
                            NSLocalizedDescriptionKey: "No data received",
                        ]
                    )
                    print("No data received for \(side)")
                    completion(.failure(error))
                    return
                }

                print("Received \(data.count) bytes for \(side)")

                if side == "front" {
                    self.imageFront = data
                } else if side == "back" {
                    self.imageBack = data
                }

                print("Successfully stored \(side) image data")
                completion(.success(()))
            }

            task.resume()
        }

        // Add the async version right after it in the class
        nonisolated func downloadImage(forSide side: String) async throws {
            return try await withCheckedThrowingContinuation { continuation in
                downloadImage(forSide: side) { result in
                    switch result {
                    case .success():
                        continuation.resume()
                    case let .failure(error):
                        continuation.resume(throwing: error)
                    }
                }
            }
        }

        static let sampleData: [StereoCard] = [
            StereoCard(
                uuid: "a0056e40-c55a-012f-e57a-58d385a7bc34",
                imageFrontId: "G91F230_029F",
                imageBackId: "G91F230_029B"
            ),
            StereoCard(
                uuid: "8f936cf0-c52e-012f-c9aa-58d385a7bc34",
                imageFrontId: "G88F105_023F",
                imageBackId: "G88F105_023B"
            ),
            StereoCard(
                uuid: "c7980740-c53b-012f-c86d-58d385a7bc34",
                imageFrontId: "G90F186_030F",
                imageBackId: "G90F186_030B"
            ),
            StereoCard(
                uuid: "f0bf5ba0-c53b-012f-dab2-58d385a7bc34",
                imageFrontId: "G90F186_122F",
                imageBackId: "G90F186_122B"
            ),
        ]

        private static func loadImageData(named imageName: String) -> Data? {
            guard
                let url = Bundle.main.url(
                    forResource: imageName, withExtension: "jpg"
                )
            else {
                return nil
            }
            return try? Data(contentsOf: url)
        }
    }
}

extension CardSchemaV1.StereoCard: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation<CardSchemaV1.StereoCard, String>(exporting: { card in
            card.uuid.uuidString
        })
    }
}
