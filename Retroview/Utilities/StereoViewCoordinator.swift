//
//  StereoViewCoordinator.swift
//  Retroview
//
//  Created by Adam Schuster on 11/9/24.
//

import Foundation
import RealityKit
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
            guard let leftCrop,
                  let rightCrop,
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
            // Process crops
            let leftImage = try CropUtility.cropImage(sourceImage, with: leftCrop)
            let rightImage = try CropUtility.cropImage(sourceImage, with: rightCrop)
            
            // Create textures concurrently
            async let leftTexture = TextureResource(image: leftImage, options: .init(semantic: .color))
            async let rightTexture = TextureResource(image: rightImage, options: .init(semantic: .color))
            
            return try await (left: leftTexture, right: rightTexture)
        }

        private func cropImage(
            _ sourceImage: CGImage, with crop: CropSchemaV1.Crop
        ) throws -> CGImage {
            let cropWidth = Int(
                CGFloat(crop.x1 - crop.x0) * CGFloat(sourceImage.width))
            let cropHeight = Int(
                CGFloat(crop.y1 - crop.y0) * CGFloat(sourceImage.height))

            guard
                let croppedContext = CGContext(
                    data: nil,
                    width: cropWidth,
                    height: cropHeight,
                    bitsPerComponent: sourceImage.bitsPerComponent,
                    bytesPerRow: 0,
                    space: sourceImage.colorSpace
                        ?? CGColorSpaceCreateDeviceRGB(),
                    bitmapInfo: sourceImage.bitmapInfo.rawValue
                )
            else {
                throw StereoError.imageProcessingFailed
            }

            // Transform to adjust for the crop
            let xOffset = -CGFloat(crop.x0) * CGFloat(sourceImage.width)
            let yOffset = -CGFloat(crop.y0) * CGFloat(sourceImage.height)
            croppedContext.translateBy(x: xOffset, y: yOffset)

            // Set the clip region to our desired crop size
            croppedContext.clip(
                to: CGRect(
                    x: Int(-xOffset), y: Int(-yOffset), width: cropWidth,
                    height: cropHeight
                ))

            // Draw the image
            croppedContext.draw(
                sourceImage,
                in: CGRect(
                    x: 0, y: 0, width: sourceImage.width,
                    height: sourceImage.height
                )
            )

            guard let croppedImage = croppedContext.makeImage() else {
                throw StereoError.imageProcessingFailed
            }

            return croppedImage
        }

        @MainActor
        private func updateMaterialAndPlane(
            content: RealityViewContent,
            material: inout ShaderGraphMaterial,
            leftTexture: TextureResource,
            rightTexture: TextureResource
        ) async throws {
            try material.setParameter(
                name: "Left", value: .textureResource(leftTexture)
            )
            try material.setParameter(
                name: "Right", value: .textureResource(rightTexture)
            )

            let dimensions = calculatePlaneDimensions(
                textureWidth: Float(leftTexture.width),
                textureHeight: Float(leftTexture.height)
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
        private func updateExistingPlane(
            _ plane: ModelEntity, with material: ShaderGraphMaterial
        ) {
            plane.model?.materials = [material]
        }

        @MainActor
        private func createPlane(
            width: Float,
            height: Float,
            material: ShaderGraphMaterial
        ) -> ModelEntity {
            let plane = ModelEntity(
                mesh: .generatePlane(width: width, height: height))
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
    }

#else
    // Empty coordinator for macOS
    class StereoViewCoordinator: ObservableObject {
        // No functionality needed for macOS
    }
#endif

//enum StereoError: Error {
//    case missingRequiredData
//    case imageProcessingFailed
//}
