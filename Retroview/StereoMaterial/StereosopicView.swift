//
//  StereoMaterial.swift
//  Retroview
//
//  Created by Adam Schuster on 6/29/24.
//

import RealityKit
import SwiftUI

@available(visionOS 2.0, *)
func createStereoscopicPlane(spriteSheet: CGImage, leftEyeRect: CGRect, rightEyeRect: CGRect) throws -> Entity {
    // Create the plane mesh
    let planeMesh = MeshResource.generatePlane(width: 1.0, height: 1.0)
    
    // Load the texture resource from the provided image
    let textureResource = try TextureResource(image: spriteSheet, options: .init(semantic: .color))
    
    // Create an UnlitMaterial with the texture
    let material = UnlitMaterial(texture: textureResource)
    
    // Create a model entity with the plane mesh and the custom material
    let modelEntity = ModelEntity(mesh: planeMesh, materials: [material])
    
    return modelEntity
}

// SwiftUI view to display the RealityKit content
@available(visionOS 2.0, *)
struct StereoscopicView: View {
    var stereoCard: CardSchemaV1.StereoCard
    @ObservedObject var viewModel: StereoCardViewModel
    
    init(stereoCard: CardSchemaV1.StereoCard) {
        self.stereoCard = stereoCard
        self.viewModel = StereoCardViewModel(stereoCard: stereoCard)
    }
    
    var body: some View {
        Group {
            if let frontCGImage = viewModel.frontCGImage {
                RealityView { content in
                    do {
                        let leftEyeRect: CGRect
                        if let leftCrop = stereoCard.leftCrop {
                            let originX = CGFloat(leftCrop.x0)
                            let originY = CGFloat(leftCrop.y0)
                            let width = CGFloat(leftCrop.x1 - leftCrop.x0)
                            let height = CGFloat(leftCrop.y1 - leftCrop.y0)
                            leftEyeRect = CGRect(x: originX, y: originY, width: width, height: height)
                        } else {
                            leftEyeRect = CGRect(x: 0, y: 0, width: 1, height: 1) // Default values if leftCrop is nil
                        }
                        
                        let rightEyeRect: CGRect
                        if let rightCrop = stereoCard.rightCrop {
                            let originX = CGFloat(rightCrop.x0)
                            let originY = CGFloat(rightCrop.y0)
                            let width = CGFloat(rightCrop.x1 - rightCrop.x0)
                            let height = CGFloat(rightCrop.y1 - rightCrop.y0)
                            rightEyeRect = CGRect(x: originX, y: originY, width: width, height: height)
                        } else {
                            rightEyeRect = CGRect(x: 0, y: 0, width: 1, height: 1) // Default values if rightCrop is nil
                        }
                        let planeEntity = try createStereoscopicPlane(spriteSheet: frontCGImage,
                                                                      leftEyeRect: leftEyeRect,
                                                                      rightEyeRect: rightEyeRect)
                        content.add(planeEntity)
                        
                    } catch {
                        print("Failed to create stereoscopic plane: \(error)")
                    }
                }
                .onAppear {
                    viewModel.loadImage(forSide: "front")
                }
            } else {
                ProgressView("Loading Front Image...")
                    .onAppear {
                        viewModel.loadImage(forSide: "front")
                    }
            }
        }
    }
}

@available(visionOS 2.0, *)
struct StereoscopicView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleCard = CardSchemaV1.StereoCard.sampleData[0]
        StereoscopicView(stereoCard: sampleCard)
    }
}
