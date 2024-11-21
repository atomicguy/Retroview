//
//  CardImporter.swift
//  Retroview
//
//  Created by Adam Schuster on 11/20/24.
//

import Foundation
import SwiftData

struct CardImporter {
    static func createCards(from jsonData: Data) async throws -> [CardSchemaV1.StereoCard] {
        try await Task.detached(priority: .userInitiated) {
            guard let jsonObject = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
                throw ImportError.invalidJSON("Failed to parse JSON")
            }
            
            // Extract required fields
            guard let uuidString = jsonObject["uuid"] as? String,
                  let titles = jsonObject["titles"] as? [String],
                  let subjects = jsonObject["subjects"] as? [String],
                  let authors = jsonObject["authors"] as? [String],
                  let dates = jsonObject["dates"] as? [String],
                  let imageIds = jsonObject["image_ids"] as? [String: String],
                  let frontImageId = imageIds["front"],
                  let backImageId = imageIds["back"],
                  let leftCropDict = jsonObject["left"] as? [String: Any],
                  let rightCropDict = jsonObject["right"] as? [String: Any]
            else {
                throw ImportError.invalidJSON("Missing required fields")
            }
            
            // Create metadata objects
            let titleObjects = titles.map { TitleSchemaV1.Title(text: $0) }
            let subjectObjects = subjects.map { SubjectSchemaV1.Subject(name: $0) }
            let authorObjects = authors.map { AuthorSchemaV1.Author(name: $0) }
            let dateObjects = dates.map { DateSchemaV1.Date(text: $0) }
            
            // Create crops
            let leftCrop = try createCrop(from: leftCropDict, side: "left")
            let rightCrop = try createCrop(from: rightCropDict, side: "right")
            
            // Create card
            let card = CardSchemaV1.StereoCard(
                uuid: uuidString,
                imageFrontId: frontImageId,
                imageBackId: backImageId,
                titles: titleObjects,
                authors: authorObjects,
                subjects: subjectObjects,
                dates: dateObjects,
                crops: [leftCrop, rightCrop]
            )
            
            return [card]
        }.value
    }
    
    private static func createCrop(from dict: [String: Any], side: String) throws -> CropSchemaV1.Crop {
        guard let x0 = dict["x0"] as? Float,
              let y0 = dict["y0"] as? Float,
              let x1 = dict["x1"] as? Float,
              let y1 = dict["y1"] as? Float,
              let score = dict["score"] as? Float
        else {
            throw ImportError.modelCreationError("Invalid crop data for \(side)")
        }
        
        return CropSchemaV1.Crop(
            x0: x0,
            y0: y0,
            x1: x1,
            y1: y1,
            score: score,
            side: side
        )
    }
}
