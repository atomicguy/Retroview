//
//  CropUtility.swift
//  Retroview
//
//  Created by Adam Schuster on 12/27/24.
//

import SwiftUI

// CropUtility.swift
enum CropUtility {
    /// Calculates the normalized rectangle for a crop region
    static func normalizedRect(for crop: CropSchemaV1.Crop) -> CGRect {
        CGRect(
            x: CGFloat(crop.x0),
            y: CGFloat(crop.y0),
            width: CGFloat(crop.x1 - crop.x0),
            height: CGFloat(crop.y1 - crop.y0)
        )
    }
    
    /// Crops a CGImage with normalized coordinates
    static func cropImage(_ sourceImage: CGImage, with crop: CropSchemaV1.Crop) throws -> CGImage {
        let rect = normalizedRect(for: crop)
        let cropWidth = Int(rect.width * CGFloat(sourceImage.width))
        let cropHeight = Int(rect.height * CGFloat(sourceImage.height))
        
        guard let context = CGContext(
            data: nil,
            width: cropWidth,
            height: cropHeight,
            bitsPerComponent: sourceImage.bitsPerComponent,
            bytesPerRow: 0,
            space: sourceImage.colorSpace ?? CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: sourceImage.bitmapInfo.rawValue
        ) else {
            throw CropError.contextCreationFailed
        }
        
        let xOffset = -CGFloat(crop.x0) * CGFloat(sourceImage.width)
        let yOffset = -CGFloat(crop.y0) * CGFloat(sourceImage.height)
        
        context.translateBy(x: xOffset, y: yOffset)
        context.clip(to: CGRect(
            x: Int(-xOffset),
            y: Int(-yOffset),
            width: cropWidth,
            height: cropHeight
        ))
        
        context.draw(sourceImage, in: CGRect(
            x: 0,
            y: 0,
            width: sourceImage.width,
            height: sourceImage.height
        ))
        
        guard let croppedImage = context.makeImage() else {
            throw CropError.imageCreationFailed
        }
        
        return croppedImage
    }
    
    enum CropError: Error {
        case contextCreationFailed
        case imageCreationFailed
    }
}
