//
//  ImageService+Crop.swift
//  Retroview
//
//  Created by Adam Schuster on 12/14/24.
//

import Foundation

struct CropParameters: Sendable {
    let x0: Float
    let y0: Float
    let x1: Float
    let y1: Float
    
    init(crop: CropSchemaV1.Crop) {
        self.x0 = crop.x0
        self.y0 = crop.y0
        self.x1 = crop.x1
        self.y1 = crop.y1
    }
}
