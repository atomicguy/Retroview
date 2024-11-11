//
//  StereoViewCoordinator.swift
//  Retroview
//
//  Created by Adam Schuster on 11/9/24.
//

import RealityKit
import SwiftUI

class StereoViewCoordinator: ObservableObject {
    var stereoMaterial: ShaderGraphMaterial?
    private var currentCardId: UUID?

    @MainActor
    func updateContent(
        content: RealityViewContent,
        sourceImage: CGImage,
        leftCrop: CropSchemaV1.Crop?,
        rightCrop: CropSchemaV1.Crop?
    ) async throws {
        print("Starting content update...")

        guard let leftCrop = leftCrop, let rightCrop = rightCrop,
            var material = stereoMaterial
        else {
            print("Missing required data:")
            print("  Left crop: \(leftCrop != nil)")
            print("  Right crop: \(rightCrop != nil)")
            print("  Material: \(stereoMaterial != nil)")
            return
        }

        print(
            "Processing source image: \(sourceImage.width)x\(sourceImage.height)"
        )

        // Create CIImage for cropping
        let ciImage = CIImage(cgImage: sourceImage)
        print("Created CIImage")

        // Create cropped images
        let leftImage = cropImage(ciImage, with: leftCrop)
        let rightImage = cropImage(ciImage, with: rightCrop)
        print("Created cropped images")

        // Convert CIImage to CGImage
        let context = CIContext()
        guard
            let leftCGImage = context.createCGImage(
                leftImage, from: leftImage.extent),
            let rightCGImage = context.createCGImage(
                rightImage, from: rightImage.extent)
        else {
            print("Failed to create CGImages from cropped images")
            throw NSError(domain: "Image Processing Error", code: -1)
        }

        print(
            "Created CGImages: Left(\(leftCGImage.width)x\(leftCGImage.height)) Right(\(rightCGImage.width)x\(rightCGImage.height))"
        )

        // Create texture resources
        print("Creating texture resources...")
        let leftTexture = try await TextureResource(
            image: leftCGImage,
            options: .init(semantic: .color)
        )
        let rightTexture = try await TextureResource(
            image: rightCGImage,
            options: .init(semantic: .color)
        )
        print("Created texture resources")

        // Update material parameters
        print("Updating material parameters...")
        try material.setParameter(
            name: "Left",
            value: .textureResource(leftTexture)
        )
        try material.setParameter(
            name: "Right",
            value: .textureResource(rightTexture)
        )
        print("Updated material parameters")

        // Calculate plane dimensions
        let (planeWidth, planeHeight) = calculatePlaneDimensions(
            textureWidth: Float(leftTexture.width),
            textureHeight: Float(leftTexture.height),
            baseSideLength: 0.352800
        )
        print("Calculated plane dimensions: \(planeWidth)x\(planeHeight)")

        // Update or create plane
        if let existingPlane = content.entities.first as? ModelEntity {
            print("Updating existing plane")
            existingPlane.model?.materials = [material]
        } else {
            print("Creating new plane")
            let plane = createPlane(
                width: planeWidth,
                height: planeHeight,
                material: material
            )
            content.add(plane)
        }

        print("Content update completed")
    }

    private func cropImage(_ image: CIImage, with crop: CropSchemaV1.Crop)
        -> CIImage
    {
        let rect = CGRect(
            x: CGFloat(crop.y0),  // Note the swap of x/y as mentioned in CardCropView
            y: CGFloat(crop.x0),
            width: CGFloat(crop.y1 - crop.y0),
            height: CGFloat(crop.x1 - crop.x0)
        )

        // Scale rect to image coordinates
        let scaledRect = rect.applying(
            CGAffineTransform(
                scaleX: CGFloat(image.extent.width),
                y: CGFloat(image.extent.height)
            )
        )

        return image.cropped(to: scaledRect)
    }

    private func calculatePlaneDimensions(
        textureWidth: Float,
        textureHeight: Float,
        baseSideLength: Float
    ) -> (width: Float, height: Float) {
        let aspectRatio = textureHeight / textureWidth

        if aspectRatio < 1 {
            return (baseSideLength, baseSideLength * aspectRatio)
        } else {
            return (baseSideLength / aspectRatio, baseSideLength)
        }
    }

    private func createPlane(
        width: Float,
        height: Float,
        material: ShaderGraphMaterial
    ) -> ModelEntity {
        let plane = ModelEntity(
            mesh: .generatePlane(width: width, height: height))
        plane.model?.materials = [material]
        plane.transform.translation = [0, 0, 0.01]  // Slight offset to prevent Z-fighting
        return plane
    }
}
