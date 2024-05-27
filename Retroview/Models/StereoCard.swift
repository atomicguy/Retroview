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
        
        var titles = [TitleSchemaV1.Title]()
        var titlePick: TitleSchemaV1.Title?
        var authors = [AuthorSchemaV1.Author]()
        var subjects = [SubjectSchemaV1.Subject]()
        var dates = [DateSchemaV1.Date]()

        init(
            uuid: String,
            imageFront: Data? = nil,
            imageFrontId: String? = "",
            imageBack: Data? = nil,
            imageBackId: String? = ""
            
        ) {
            self.uuid = UUID(uuidString: uuid) ?? UUID()
            self.imageFrontId = imageFrontId
            self.imageBackId = imageBackId
        }
        
        func imageUrl(forSide side: String ) -> URL? {
            let baseUrl = "https://iiif-prod.nypl.org/index.php?id="
            let size = "&t=w"
            var imageName = imageFrontId
            if (side == "back") {
                imageName = imageBackId
            }
            let imageUrl = baseUrl + (imageName ?? "unknown") + size
//            print(imageUrl)
            return URL(string: imageUrl)
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

//enum CardSchemaV2: VersionedSchema {
//    static var versionIdentifier: Schema.Version = .init(0,2,0)
//    
//    static var models: [any PersistentModel.Type] {
//        [StereoCard.self, TitleSchemaV1.Title.self, AuthorSchemaV1.Author.self, SubjectSchemaV1.Subject.self, DateSchemaV1.Date.self]
//    }
//    
//    @Model
//    class StereoCard {
//        @Attribute(.unique) 
//        var uuid: String
//        @Relationship(inverse: \TitleSchemaV1.Title.cards)
//        var titles: [TitleSchemaV1.Title]
//        @Relationship(inverse: \AuthorSchemaV1.Author.cards)
//        var authors: [AuthorSchemaV1.Author]
//        @Relationship(inverse: \SubjectSchemaV1.Subject.cards)
//        var subjects: [SubjectSchemaV1.Subject]
//        @Relationship(inverse: \DateSchemaV1.Date.cards)
//        var dates: [DateSchemaV1.Date]
//        var rating: Int?
//        var imageIdFront: String
//        var imageIdBack: String?
//        @Relationship(deleteRule: .cascade)
//        var left: CropSchemaV1.Crop?
//        @Relationship(deleteRule: .cascade)
//        var right: CropSchemaV1.Crop?
//        
//        init(
//            uuid: String,
//            titles: [TitleSchemaV1.Title],
//            authors: [AuthorSchemaV1.Author],
//            subjects: [SubjectSchemaV1.Subject],
//            dates: [DateSchemaV1.Date],
//            rating: Int? = nil,
//            imageIdFront: String,
//            imageIdBack: String?,
//            left: CropSchemaV1.Crop?,
//            right: CropSchemaV1.Crop?
//            
//        ) {
//            self.uuid = uuid
//            self.titles = titles
//            self.authors = authors
//            self.subjects = subjects
//            self.dates = dates
//            self.rating = rating
//            self.imageIdFront = imageIdFront
//            self.imageIdBack = imageIdBack
//            self.left = left
//            self.right = right
//        }
//        
//        static func example() -> StereoCard {
//            let card = StereoCard(
//                uuid: "c7980740-c53b-012f-c86d-58d385a7bc34",
//                titles: [
//                    TitleSchemaV1.Title(
//                        text: "Bird's-eye view, Columbian Exposition."
//                    ),
//                    TitleSchemaV1.Title(text: "Stereoscopic views of the World's Columbian Exposition. 7972.")
//                ],
//                authors: [
//                    AuthorSchemaV1.Author(
//                        name: "Kilburn, B. W. (Benjamin West) (1827-1909)"
//                    )
//                ],
//                subjects: [
//                    SubjectSchemaV1.Subject(
//                        name: "Chicago (Ill.)"
//                    ),
//                    SubjectSchemaV1.Subject(
//                        name: "Illinois"
//                    ),
//                    SubjectSchemaV1.Subject(
//                        name: "World's Columbian Exposition (1893 : Chicago, Ill.)"
//                    ),
//                    SubjectSchemaV1.Subject(
//                        name: "Exhibitions"
//                    )
//                ],
//                dates: [
//                    DateSchemaV1.Date(
//                        text: "1893"
//                    )
//                ],
//                imageIdFront: "IMG123f",
//                imageIdBack: "IMG123b",
//                left: CropSchemaV1.Crop(
//                    x0: 0.0,
//                    y0: 0.0,
//                    x1: 0.0,
//                    y1: 0.0,
//                    score: 0.9,
//                    side: "left"
//                ),
//                right: CropSchemaV1.Crop(
//                    x0: 0.0,
//                    y0: 0.0,
//                    x1: 0.0,
//                    y1: 0.0,
//                    score: 0.9,
//                    side: "right"
//                )
//            )
//            
//            return card
//        }
//    }
//}
