//
//  StereoscopicCardView.swift
//  Retroview
//
//  Created by Adam Schuster on 7/1/24.
//

import SwiftUI
import RealityKit
import ARKit

@available(visionOS 2.0, *)
struct StereoscopicCardView: View {
    @ObservedObject var viewModel: StereoCardViewModel

    var body: some View {
        RealityView { content in
            // Create a parent entity to hold our stereo images
            let rootEntity = Entity()

            // Create and position left eye image
            if let leftImage = viewModel.getCroppedImage(for: .left) {
                let leftPlane = createImagePlane(from: leftImage, for: .left)
                rootEntity.addChild(leftPlane)
            }

            // Create and position right eye image
            if let rightImage = viewModel.getCroppedImage(for: .right) {
                let rightPlane = createImagePlane(from: rightImage, for: .right)
                rootEntity.addChild(rightPlane)
            }

            // Add the root entity to the content
            content.add(rootEntity)
        }
    }

    private func createImagePlane(from image: CGImage, for eye: StereoCardViewModel.Eye) -> ModelEntity {
        let texture = try! TextureResource(image: image, options: .init(semantic: .color))
        var material = UnlitMaterial()
        material.color = .init(texture: .init(texture))

        let mesh = MeshResource.generatePlane(width: 0.1, height: 0.1)
        let entity = ModelEntity(mesh: mesh, materials: [material])

        // Position the plane slightly to the left or right based on the eye
        entity.position = eye == .left ? [-0.05, 0, -0.1] : [0.05, 0, -0.1]

        return entity
    }
}

#Preview {
    let sampleCard = CardSchemaV1.StereoCard.sampleData[0]
    let viewModel = StereoCardViewModel(stereoCard: sampleCard)
    if #available(visionOS 2.0, *) {
        StereoscopicCardView(viewModel: viewModel)
            .modelContainer(SampleData.shared.modelContainer)
    } else {
        // Fallback on earlier versions
    }
}
