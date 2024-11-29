//
//  JSONStructures.swift
//  Retroview
//
//  Created by Adam Schuster on 11/27/24.
//

import Foundation

struct StereoCardJSON: Codable {
    let uuid: String
    let titles: [String]
    let subjects: [String]
    let authors: [String]
    let dates: [String]
    let imageIds: ImageIDs
    let left: CropData
    let right: CropData

    enum CodingKeys: String, CodingKey {
        case uuid, titles, subjects, authors, dates
        case imageIds = "image_ids"
        case left, right
    }
}

struct ImageIDs: Codable {
    let front: String
    let back: String
}

struct CropData: Codable {
    let x0: Float
    let y0: Float
    let x1: Float
    let y1: Float
    let score: Float
    let side: String
}
