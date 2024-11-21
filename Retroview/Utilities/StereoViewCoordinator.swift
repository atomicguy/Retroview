//
//  StereoViewCoordinator.swift
//  Retroview
//
//  Created by Adam Schuster on 11/9/24.
//

import Foundation
import SwiftUI

#if os(visionOS)
import RealityKit
import StereoViewer

class StereoViewCoordinator: ObservableObject {
    var stereoMaterial: ShaderGraphMaterial?
    
    @MainActor
    func updateContent(
        content: RealityViewContent,
        sourceImage: CGImage,
        leftCrop: CropSchemaV1.Crop?,
        rightCrop: CropSchemaV1.Crop?
    ) async throws {
        // Existing visionOS implementation
        guard let leftCrop = leftCrop,
              let rightCrop = rightCrop,
              var material = stereoMaterial
        else {
            throw StereoError.missingRequiredData
        }
        
        let (leftTexture, rightTexture) = try await createTexturesFromCrops(
            sourceImage: sourceImage,
            leftCrop: leftCrop,
            rightCrop: rightCrop
        )
        
        try await updateMaterialAndPlane(
            content: content,
            material: &material,
            leftTexture: leftTexture,
            rightTexture: rightTexture
        )
    }
    
    private func createTexturesFromCrops(
        sourceImage: CGImage,
        leftCrop: CropSchemaV1.Crop,
        rightCrop: CropSchemaV1.Crop
    ) async throws -> (left: TextureResource, right: TextureResource) {
        let ciImage = CIImage(cgImage: sourceImage)
        let context = CIContext()
        
        let leftCropped = cropImage(ciImage, with: leftCrop)
        let rightCropped = cropImage(ciImage, with: rightCrop)
        
        guard let leftCGImage = context.createCGImage(leftCropped, from: leftCropped.extent),
              let rightCGImage = context.createCGImage(rightCropped, from: rightCropped.extent)
        else {
            throw StereoError.imageProcessingFailed
        }
        
        async let leftTexture = TextureResource(image: leftCGImage, options: .init(semantic: .color))
        async let rightTexture = TextureResource(image: rightCGImage, options: .init(semantic: .color))
        
        return try await (left: leftTexture, right: rightTexture)
    }
    
    @MainActor
    private func updateMaterialAndPlane(
        content: RealityViewContent,
        material: inout ShaderGraphMaterial,
        leftTexture: TextureResource,
        rightTexture: TextureResource
    ) async throws {
        try material.setParameter(name: "Left", value: .textureResource(leftTexture))
        try material.setParameter(name: "Right", value: .textureResource(rightTexture))
        
        // These are synchronous operations, no await needed
        let textureWidth = Float(leftTexture.width)
        let textureHeight = Float(leftTexture.height)
        
        let dimensions = calculatePlaneDimensions(
            textureWidth: textureWidth,
            textureHeight: textureHeight
        )
        
        if let existingPlane = content.entities.first as? ModelEntity {
            updateExistingPlane(existingPlane, with: material)
        } else {
            let plane = createPlane(
                width: dimensions.width,
                height: dimensions.height,
                material: material
            )
            content.add(plane)
        }
    }

    @MainActor
    private func updateExistingPlane(_ plane: ModelEntity, with material: ShaderGraphMaterial) {
        plane.model?.materials = [material]
    }

    @MainActor
    private func createPlane(
        width: Float,
        height: Float,
        material: ShaderGraphMaterial
    ) -> ModelEntity {
        let plane = ModelEntity(mesh: .generatePlane(width: width, height: height))
        plane.model?.materials = [material]
        plane.transform.translation = [0, 0, 0.01]
        return plane
    }

    private func calculatePlaneDimensions(
        textureWidth: Float,
        textureHeight: Float,
        baseSideLength: Float = 0.352800
    ) -> (width: Float, height: Float) {
        let aspectRatio = textureHeight / textureWidth
        return aspectRatio < 1
            ? (baseSideLength, baseSideLength * aspectRatio)
            : (baseSideLength / aspectRatio, baseSideLength)
    }
    
    private func cropImage(_ image: CIImage, with crop: CropSchemaV1.Crop) -> CIImage {
        let rect = CGRect(
            x: CGFloat(crop.y0),
            y: CGFloat(crop.x0),
            width: CGFloat(crop.y1 - crop.y0),
            height: CGFloat(crop.x1 - crop.x0)
        )
        
        let scaledRect = rect.applying(
            CGAffineTransform(
                scaleX: CGFloat(image.extent.width),
                y: CGFloat(image.extent.height)
            )
        )
        
        return image.cropped(to: scaledRect)
    }
}

#else
// Empty coordinator for macOS
class StereoViewCoordinator: ObservableObject {
    // No functionality needed for macOS
}
#endif

enum StereoError: Error {
    case missingRequiredData
    case imageProcessingFailed
}
