////
////  Import.swift
////  Retroview
////
////  Created by Adam Schuster on 4/21/24.
////
//
//import Foundation
//import SwiftData
//
//struct JSONCard: Codable {
//    let uuid: String
//    let titles: [String]
//    let subjects: [String]
//    let authors: [String]
//    let dates: [String]
//    let image_ids: ImageIDs
//    let left: CropData
//    let right: CropData
//    
//    struct ImageIDs: Codable {
//        let front: String
//        let back: String?
//    }
//    
//    struct CropData: Codable {
//        let x0: Float
//        let y0: Float
//        let x1: Float
//        let y1: Float
//        let score: Float
//        let side: String
//    }
//}
//
//class JSONImporter {
//    private let store: ModelContainer
//    
//    init(store: ModelContainer) {
//        self.store = store
//    }
//    
//    func importFromJSON(from url: URL) throws {
//        let data = try Data(contentsOf: url)
//        let decoder = JSONDecoder()
//        let cards = try decoder.decode([JSONCard].self, from: data)
//        
//        try store.saveModels(cards.map { importCard($0) }, updatePolicy: .overwrite)
//    }
//    
//    private func importCard(_ jsonCard: JSONCard) -> CardSchemaV1.StereoCard {
//        let titles = jsonCard.titles.map { TitleSchemaV1.Title(text: $0) }
//         
//        // Fetch existing authors, subjects, and dates from the persistent store
//        let existingAuthors = try store.fetchAll(AuthorSchemaV1.Author.self, sortDescriptors: [])
//        let existingSubjects = try store.fetchAll(SubjectSchemaV1.Subject.self, sortDescriptors: [])
//        let existingDates = try store.fetchAll(DateSchemaV1.Date.self, sortDescriptors: [])
//            
//        let authors: [AuthorSchemaV1.Author] = jsonCard.authors.compactMap { authorName in
//                if let existingAuthor = existingAuthors.first(where: { $0.name == authorName }) {
//                    return existingAuthor
//                } else {
//                    return AuthorSchemaV1.Author(name: authorName)
//                }
//            }
//            
//        let subjects: [SubjectSchemaV1.Subject] = jsonCard.subjects.compactMap { subjectName in
//                if let existingSubject = existingSubjects.first(where: { $0.name == subjectName }) {
//                    return existingSubject
//                } else {
//                    return SubjectSchemaV1.Subject(name: subjectName)
//                }
//            }
//            
//        let dates: [DateSchemaV1.Date] = jsonCard.dates.compactMap { dateText in
//                if let existingDate = existingDates.first(where: { $0.text == dateText }) {
//                    return existingDate
//                } else {
//                    return DateSchemaV1.Date(text: dateText)
//                }
//            }
//        
//        let left = CropSchemaV1.Crop(
//            x0: jsonCard.left.x0,
//            y0: jsonCard.left.y0,
//            x1: jsonCard.left.x1,
//            y1: jsonCard.left.y1,
//            score: jsonCard.left.score,
//            side: jsonCard.left.side
//        )
//        
//        let right = CropSchemaV1.Crop(
//            x0: jsonCard.right.x0,
//            y0: jsonCard.right.y0,
//            x1: jsonCard.right.x1,
//            y1: jsonCard.right.y1,
//            score: jsonCard.right.score,
//            side: jsonCard.right.side
//        )
//        
//        return CardSchemaV1.StereoCard(
//            uuid: jsonCard.uuid,
//            titles: titles,
//            authors: authors,
//            subjects: subjects,
//            dates: dates,
//            rating: nil,
//            imageIdFront: jsonCard.image_ids.front,
//            imageIdBack: jsonCard.image_ids.back,
//            left: left,
//            right: right
//        )
//    }
//}
