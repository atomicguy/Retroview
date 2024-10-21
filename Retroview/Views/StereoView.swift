//
//  StereoView.swift
//  Retroview
//
//  Created by Adam Schuster on 10/20/24.
//

import RealityKit
import StereoViewer
import SwiftUI

struct StereoView: View {
    let card: CardSchemaV1.StereoCard
    @StateObject private var coordinator = StereoViewCoordinator()
    @StateObject private var viewModel: StereoCardViewModel
    @State private var content: RealityViewContent? = nil  // Store content here

    init(card: CardSchemaV1.StereoCard) {
        self.card = card
        _viewModel = StateObject(
            wrappedValue: StereoCardViewModel(stereoCard: card))
    }

    var body: some View {
        GeometryReader { geometry in
            VStack {
                if let title = card.titlePick?.text {
                    Text(title)
                        .font(.title)
                }

                RealityView { newContent in
                    // Capture RealityView content and store it in @State
                    // Create a local copy of newContent to avoid inout capture
                    let capturedContent = newContent
                    DispatchQueue.main.async {
                        self.content = capturedContent  // Store content in state
                    }
                } update: { newContent in
                    Task {
                        if let cgImage = viewModel.frontCGImage {
                            do {
                                // Use stored content (from @State), not the inout parameter
                                if let storedContent = self.content {
                                    try await coordinator.updateContent(
                                        content: storedContent,  // Use stored content
                                        sourceImage: cgImage,
                                        leftCrop: card.leftCrop,
                                        rightCrop: card.rightCrop
                                    )
                                }
                            } catch {
                                print("Error updating content: \(error.localizedDescription)")
                            }
                        }
                    }
                }
            }
            .onAppear {
                // Trigger asynchronous setup outside the view-building phase
                Task {
                    do {
                        if coordinator.stereoMaterial == nil {
                            coordinator.stereoMaterial =
                                try await ShaderGraphMaterial(
                                    named: "/Root/StereoMaterial",
                                    from: "StereoViewer.usda",
                                    in: stereoViewerBundle
                                )
                        }

                        // Load the front image if not already loaded
                        viewModel.loadImage(forSide: "front")
                    } catch {
                        print("Error loading stereo material: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}

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
        guard let leftCrop = leftCrop, let rightCrop = rightCrop,
              var material = stereoMaterial
        else {
            print("Missing required data for stereo view")
            return
        }

        // Create CIImage for cropping
        let ciImage = CIImage(cgImage: sourceImage)

        // Create cropped images
        let leftImage = cropImage(ciImage, with: leftCrop)
        let rightImage = cropImage(ciImage, with: rightCrop)

        // Convert CIImage to CGImage
        let context = CIContext()
        guard
            let leftCGImage = context.createCGImage(
                leftImage, from: leftImage.extent),
            let rightCGImage = context.createCGImage(
                rightImage, from: rightImage.extent)
        else {
            throw NSError(domain: "Image Processing Error", code: -1)
        }

        // Create texture resources
        let leftTexture = try await TextureResource(image: leftCGImage, options: .init(semantic: TextureResource.Semantic.color))
        let rightTexture = try await TextureResource(image: rightCGImage, options: .init(semantic: TextureResource.Semantic.color))

        // Update material parameters
        try material.setParameter(
            name: "LeftImage", value: .textureResource(leftTexture))
        try material.setParameter(
            name: "RightImage", value: .textureResource(rightTexture))

        // Calculate plane dimensions
        let (planeWidth, planeHeight) = calculatePlaneDimensions(
            textureWidth: Float(leftTexture.width),
            textureHeight: Float(leftTexture.height),
            baseSideLength: 0.352800
        )

        // Update or create plane
        if let existingPlane = content.entities.first as? ModelEntity {
            existingPlane.model?.materials = [material]
        } else {
            let plane = createPlane(
                width: planeWidth,
                height: planeHeight,
                material: material
            )
            content.add(plane)
        }
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

        if (aspectRatio < 1) {
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

#Preview {
    StereoView(card: SampleData.shared.card)
        .modelContainer(SampleData.shared.modelContainer)
}
