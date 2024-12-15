//
//  CropImportTypes.swift
//  Retroview
//
//  Created by Adam Schuster on 12/14/24.
//

import Foundation

struct CropUpdateJSON: Codable {
    let uuid: String
    let left: CropDetailsJSON
    let right: CropDetailsJSON
}

struct CropDetailsJSON: Codable {
    let x0: Float
    let y0: Float
    let x1: Float
    let y1: Float
    let score: Float
    let `class`: String
    
    // Computed property to convert class to side
    var side: String {
        `class` // The JSON uses "class" but our model uses "side"
    }
}
