//
//  CroppedImageView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/9/24.
//

import SwiftUI

struct CroppedImageView: View {
    let image: CGImage
    let crop: CropSchemaV1.Crop
    let geometry: GeometryProxy
    
    var body: some View {
        let cropWidth = CGFloat(crop.y1 - crop.y0)
        let cropHeight = CGFloat(crop.x1 - crop.x0)
        let scale = min(
            geometry.size.width / (cropWidth * CGFloat(image.width)),
            geometry.size.height / (cropHeight * CGFloat(image.height))
        )
        
        Image(decorative: image, scale: 1.0)
            .resizable()
            .scaledToFill()
            .frame(
                width: CGFloat(image.width) * scale,
                height: CGFloat(image.height) * scale
            )
            .offset(
                x: -CGFloat(crop.y0) * CGFloat(image.width) * scale,
                y: -CGFloat(crop.x0) * CGFloat(image.height) * scale
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
    }
}

//#Preview {
//    GeometryReader { geometry in
//        CroppedImageView(
//            image: // Preview image would go here,
//            crop: CropSchemaV1.Crop(
//                x0: 0.1,
//                y0: 0.1,
//                x1: 0.9,
//                y1: 0.9,
//                score: 1.0,
//                side: "left"
//            ),
//            geometry: geometry
//        )
//    }
//    .frame(width: 300, height: 300)
//}
