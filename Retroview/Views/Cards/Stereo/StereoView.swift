//
//  StereoView.swift
//  Retroview
//
//  Created by Adam Schuster on 10/20/24.

#if os(visionOS)
import RealityKit
import StereoViewer

struct StereoView: View {
    let card: CardSchemaV1.StereoCard
    @StateObject private var viewModel: StereoViewModel
    @StateObject private var materialLoader = StereoMaterialLoader()
    @State private var content: RealityViewContent?
    
    init(card: CardSchemaV1.StereoCard) {
        self.card = card
        _viewModel = StateObject(wrappedValue: StereoViewModel(card: card))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let image = viewModel.cardImage {
                    RealityView { content in
                        self.content = content
                    } update: { content in
                        Task {
                            try await updateStereoView(content: content, image: image)
                        }
                    }
                } else {
                    LoadingIndicator(message: "Loading stereo view...")
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .task {
                await materialLoader.loadMaterial()
                try? await viewModel.loadStereoImage()
            }
        }
    }
    
    private func updateStereoView(content: RealityViewContent, image: CGImage) async throws {
        guard let material = materialLoader.material,
              let leftCrop = card.crops.first(where: { $0.side == "left" }),
              let rightCrop = card.crops.first(where: { $0.side == "right" }) else {
            return
        }
        
        // Create textures from crops
        let leftTexture = try await createTexture(from: image, crop: leftCrop)
        let rightTexture = try await createTexture(from: image, crop: rightCrop)
        
        // Update material parameters
        try material.setParameter(name: "Left", value: .textureResource(leftTexture))
        try material.setParameter(name: "Right", value: .textureResource(rightTexture))
        
        // Create or update plane
        updatePlane(in: content, with: material, leftTexture: leftTexture)
    }
}
#endif
