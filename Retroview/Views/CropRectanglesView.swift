//
//  CropRectanglesView.swift
//  Retroview
//
//  Created by Adam Schuster on 1/4/25.
//

import SwiftUI

struct CropRectanglesView: View {
    let leftCrop: CropSchemaV1.Crop?
    let rightCrop: CropSchemaV1.Crop?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {
                // Left crop overlay
                if let leftCrop {
                    let cropRect = CropUtility.normalizedRect(for: leftCrop)
                    Rectangle()
                        .strokeBorder(Color.red, lineWidth: 4)
                        .frame(
                            width: geometry.size.width * cropRect.width,
                            height: geometry.size.height * cropRect.height
                        )
                        .position(
                            x: geometry.size.width * (cropRect.minX + cropRect.width/2),
                            y: geometry.size.height * (cropRect.minY + cropRect.height/2)
                        )
                }
                
                // Right crop overlay
                if let rightCrop {
                    let cropRect = CropUtility.normalizedRect(for: rightCrop)
                    Rectangle()
                        .strokeBorder(Color.blue, lineWidth: 4)
                        .frame(
                            width: geometry.size.width * cropRect.width,
                            height: geometry.size.height * cropRect.height
                        )
                        .position(
                            x: geometry.size.width * (cropRect.minX + cropRect.width/2),
                            y: geometry.size.height * (cropRect.minY + cropRect.height/2)
                        )
                }
            }
        }
    }
}

#Preview {
    let leftCrop = CropSchemaV1.Crop(
        x0: 0.1, y0: 0.1,
        x1: 0.4, y1: 0.9,
        score: 1.0,
        side: "left"
    )
    
    let rightCrop = CropSchemaV1.Crop(
        x0: 0.6, y0: 0.1,
        x1: 0.9, y1: 0.9,
        score: 1.0,
        side: "right"
    )
    
    return CropRectanglesView(leftCrop: leftCrop, rightCrop: rightCrop)
        .frame(width: 400, height: 300)
        .border(.gray)
}
