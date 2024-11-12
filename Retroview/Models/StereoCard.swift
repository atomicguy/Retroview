//
//  Stereoview.swift
//  Retroview
//
//  Created by Adam Schuster on 4/6/24.
//

import Foundation
import SwiftData

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

        enum CodingKeys: String, CodingKey {
            case uuid, imageFrontId, imageBackId
        }

        required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.uuid = try container.decode(UUID.self, forKey: .uuid)
            self.imageFrontId = try container.decodeIfPresent(String.self, forKey: .imageFrontId)
            self.imageBackId = try container.decodeIfPresent(String.self, forKey: .imageBackId)
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(uuid, forKey: .uuid)
            try container.encodeIfPresent(imageFrontId, forKey: .imageFrontId)
            try container.encodeIfPresent(imageBackId, forKey: .imageBackId)
        }

        init(
            uuid: String,
            imageFront: Data? = nil,
            imageFrontId: String? = "",
            imageBack: Data? = nil,
            imageBackId: String? = "",
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
                completion(
                    .failure(
                        NSError(
                            domain: "", code: 0,
                            userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
                return
            }

            let task = URLSession.shared.dataTask(with: url) {
                data, _, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }

                guard let data = data else {
                    completion(
                        .failure(
                            NSError(
                                domain: "", code: 0,
                                userInfo: [
                                    NSLocalizedDescriptionKey:
                                        "No data received",
                                ])))
                    return
                }

                if side == "front" {
                    self.imageFront = data
                } else if side == "back" {
                    self.imageBack = data
                }

                completion(.success(()))
            }

            task.resume()
        }

        static let sampleData: [StereoCard] = [
            StereoCard(
                uuid: "c7980740-c53b-012f-c86d-58d385a7bc34",
                imageFrontId: "G90F186_030F",
                imageBackId: "G90F186_030B"),
            StereoCard(
                uuid: "f0bf5ba0-c53b-012f-dab2-58d385a7bc34",
                imageFrontId: "G90F186_122F",
                imageBackId: "G90F186_122B"),
        ]

        private static func loadImageData(named imageName: String) -> Data? {
            guard
                let url = Bundle.main.url(
                    forResource: imageName, withExtension: "jpg")
            else {
                return nil
            }
            return try? Data(contentsOf: url)
        }
    }
}

// Add this extension to StereoCard.swift

extension CardSchemaV1.StereoCard {
    /// Downloads an image for the specified side and stores it in the model
    /// - Parameter side: The side of the card ("front" or "back")
    /// - Throws: Error if download fails or URL is invalid
    func downloadImage(forSide side: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            self.downloadImage(forSide: side) { result in
                switch result {
                case .success():
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
