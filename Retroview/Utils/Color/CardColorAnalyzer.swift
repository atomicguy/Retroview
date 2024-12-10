//
//  CardColorAnalyzer.swift
//  Retroview
//
//  Created by Adam Schuster on 12/9/24.
//

import CoreGraphics
import SwiftUI

enum CardColorAnalyzer {
    static func extractCardstockColor(from image: CGImage) -> Color? {
        let width = image.width
        let height = image.height
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        var pixelData = [UInt8](repeating: 0, count: bytesPerRow * height)
        
        let context = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        )
        
        context?.draw(image, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        var totalR = 0
        var totalG = 0
        var totalB = 0
        var samples = 0
        
        for y in stride(from: height/3, to: 2*height/3, by: 5) {
            for x in stride(from: width/3, to: 2*width/3, by: 5) {
                let offset = Int(y * bytesPerRow + x * bytesPerPixel)
                guard offset + 2 < pixelData.count else { continue }
                
                totalR += Int(pixelData[offset])
                totalG += Int(pixelData[offset + 1])
                totalB += Int(pixelData[offset + 2])
                samples += 1
            }
        }
        
        guard samples > 0 else { return nil }
        
        return Color(
            red: Double(totalR) / Double(samples) / 255,
            green: Double(totalG) / Double(samples) / 255,
            blue: Double(totalB) / Double(samples) / 255
        )
    }
}
