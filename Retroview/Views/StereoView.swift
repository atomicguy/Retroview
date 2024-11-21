//
//  StereoView.swift
//  Retroview
//
//  Created by Adam Schuster on 10/20/24.

import SwiftData
import SwiftUI

#if os(visionOS)
import RealityKit
import StereoViewer

struct StereoView: View {
    let card: CardSchemaV1.StereoCard
    @StateObject private var coordinator = StereoViewCoordinator()
    @StateObject private var viewModel: StereoCardViewModel
    @StateObject private var materialLoader = StereoMaterialLoader()
    @State private var content: RealityViewContent?
    @State private var showDebug = true
    @State private var errorMessage: String?

    init(card: CardSchemaV1.StereoCard) {
        self.card = card
        _viewModel = StateObject(wrappedValue: StereoCardViewModel(stereoCard: card))
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                mainView(geometry: geometry)
                if showDebug {
                    DebugOverlay(
                        hasImage: viewModel.frontCGImage != nil,
                        imageSize: imageSize,
                        hasCrops: card.leftCrop != nil && card.rightCrop != nil,
                        leftCrop: card.leftCrop?.description ?? "none",
                        rightCrop: card.rightCrop?.description ?? "none",
                        hasMaterial: materialLoader.material != nil,
                        error: errorMessage
                    )
                }
            }
        }
        .task {
            do {
                await materialLoader.loadMaterial()
                coordinator.stereoMaterial = materialLoader.material
                try await viewModel.loadImage(forSide: "front")
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private var imageSize: String {
        guard let image = viewModel.frontCGImage else { return "none" }
        return "\(image.width)x\(image.height)"
    }

    private func mainView(geometry: GeometryProxy) -> some View {
        RealityView { content in
            self.content = content
        } update: { content in
            let contentCopy = content
            Task { @MainActor in
                if let image = viewModel.frontCGImage {
                    do {
                        try await coordinator.updateContent(
                            content: contentCopy,
                            sourceImage: image,
                            leftCrop: card.leftCrop,
                            rightCrop: card.rightCrop
                        )
                    } catch {
                        print("Error updating reality view: \(error)")
                    }
                }
            }
        }
        .frame(width: geometry.size.width, height: geometry.size.height)
    }
}

#else
// macOS version - simplified view without stereo functionality
struct StereoView: View {
    let card: CardSchemaV1.StereoCard
    @StateObject private var viewModel: StereoCardViewModel

    init(card: CardSchemaV1.StereoCard) {
        self.card = card
        _viewModel = StateObject(wrappedValue: StereoCardViewModel(stereoCard: card))
    }

    var body: some View {
        VStack(spacing: 16) {
            Text("Stereo View")
                .font(.title)

            if let frontImage = viewModel.frontCGImage {
                Image(decorative: frontImage, scale: 1.0)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxHeight: 400)
            }

            Text("Stereo viewing is only available on Vision Pro")
                .foregroundStyle(.secondary)
        }
        .padding()
        .task {
            try? await viewModel.loadImage(forSide: "front")
        }
    }
}
#endif

// MARK: - Debug Overlay

private struct DebugOverlay: View {
    let hasImage: Bool
    let imageSize: String
    let hasCrops: Bool
    let leftCrop: String
    let rightCrop: String
    let hasMaterial: Bool
    let error: String?

    var body: some View {
        VStack {
            Text(debugDescription)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.green)
                .padding()
                .background(Color.black.opacity(0.7))
                .cornerRadius(8)
                .padding()

            if let error = error {
                Text("Error: \(error)")
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(8)
            }

            Spacer()
        }
    }

    private var debugDescription: String {
        """
        Image Loaded: \(hasImage)
        Image Size: \(imageSize)
        Has Crops: \(hasCrops)
        Left Crop: \(leftCrop)
        Right Crop: \(rightCrop)
        Material Loaded: \(hasMaterial)
        """
    }
}

// MARK: - Preview Support

struct StereoViewPreview: View {
    var body: some View {
        StereoView(card: SampleData.shared.card)
            .modelContainer(SampleData.shared.modelContainer)
            .environmentObject(WindowStateManager.shared)
    }
}

#Preview {
    StereoViewPreview()
}
