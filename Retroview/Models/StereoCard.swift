//
//  Stereoview.swift
//  Retroview
//
//  Created by Adam Schuster on 4/6/24.
//

import Foundation
import SwiftData

enum CardSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version = .init(0,1,0)
    
    static var models: [any PersistentModel.Type] {
        [CardSchemaV1.StereoCard.self, TitleSchemaV1.Title.self, AuthorSchemaV1.Author.self, SubjectSchemaV1.Subject.self, DateSchemaV1.Date.self]
    }
    
    static var imageURLTemplate = "https://iiif-prod.nypl.org/index.php?id=%@&t=w"
    
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
        @Relationship(inverse: \CropSchemaV1.Crop.card)
        var leftCrop: CropSchemaV1.Crop?
        @Relationship(inverse: \CropSchemaV1.Crop.card)
        var rightCrop: CropSchemaV1.Crop?

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
                leftCrop: CropSchemaV1.Crop? = nil,
                rightCrop: CropSchemaV1.Crop? = nil
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
                self.leftCrop = leftCrop
                self.rightCrop = rightCrop
            }
        
        func imageUrl(forSide side: String ) -> URL? {
            let baseUrl = "https://iiif-prod.nypl.org/index.php?id="
            let sizeSuffix = "&t=w"
            var imageName = imageFrontId
            if (side == "back") {
                imageName = imageBackId
            }
            let imageUrl = baseUrl + (imageName ?? "unknown") + sizeSuffix
            return URL(string: imageUrl)
        }
        
        // Function to download image and store it as external storage
        func downloadImage(forSide side: String, completion: @escaping (Result<Void, Error>) -> Void) {
            guard let url = imageUrl(forSide: side) else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
                return
            }
            
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
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
        
        static let sampleData: [StereoCard] = {
            
            return [
                StereoCard(
                    uuid: "c7980740-c53b-012f-c86d-58d385a7bc34",
                    imageFrontId: "G90F186_030F",
                    imageBackId: "G90F186_030B"
                ),
                StereoCard(
                    uuid: "f0bf5ba0-c53b-012f-dab2-58d385a7bc34",
                    imageFrontId: "G90F186_122F",
                    imageBackId: "G90F186_122B"
                )
            ]
        }()
        
        private static func loadImageData(named imageName: String) -> Data? {
            guard let url = Bundle.main.url(forResource: imageName, withExtension: "jpg") else {
                           return nil
                       }
                       return try? Data(contentsOf: url)
        }
    }
}
