//
//  StereoCardViewModel.swift
//  Retroview
//
//  Created by Adam Schuster on 6/9/24.
//

import CoreGraphics
import Foundation
import SwiftUI

@MainActor
class StereoCardViewModel: ObservableObject {
    @Published var stereoCard: CardSchemaV1.StereoCard
    @Published var frontCGImage: CGImage?
    @Published var backCGImage: CGImage?
    @Published var isLoadingFront = false
    @Published var isLoadingBack = false
    private var loadingTasks: [String: Task<Void, Error>] = [:]

    private let imageLoader: DefaultImageLoader

    init(
        stereoCard: CardSchemaV1.StereoCard,
        imageLoader: DefaultImageLoader = DefaultImageLoader()
    ) {
        self.stereoCard = stereoCard
        self.imageLoader = imageLoader
    }

    func updateCardColor(from image: CGImage) {
        if let newColor = CardColorAnalyzer.extractCardstockColor(from: image) {
            stereoCard.color = newColor
        }
    }

    func loadImage(forSide side: String) async throws {
        // Cancel any existing loading task for this side
        loadingTasks[side]?.cancel()

        let task = Task { @MainActor in
            if side == "front" {
                isLoadingFront = true
                do { isLoadingFront = false }
            } else {
                isLoadingBack = true
                do { isLoadingBack = false }
            }

            let imageData =
                side == "front" ? stereoCard.imageFront : stereoCard.imageBack

            if let data = imageData {
                if let cgImage = await imageLoader.createCGImage(from: data) {
                    if side == "front" {
                        frontCGImage = cgImage
                    } else {
                        backCGImage = cgImage
                        // Add color extraction here, after successfully loading the back image
                        updateCardColor(from: cgImage)
                    }
                } else if let cgImage =
                    await imageLoader.createCGImageAlternative(from: data)
                {
                    if side == "front" {
                        frontCGImage = cgImage
                    } else {
                        backCGImage = cgImage
                        // And here as well for the alternative loading path
                        updateCardColor(from: cgImage)
                    }
                } else {
                    throw NSError(
                        domain: "", code: 0,
                        userInfo: [
                            NSLocalizedDescriptionKey: "Failed to create image",
                        ]
                    )
                }
            } else {
                try await downloadAndLoadImage(forSide: side)
            }
        }

        if side == "back", backCGImage != nil {
            // Update color when back image is loaded
            updateCardColor(from: backCGImage!)
        }

        loadingTasks[side] = task
        try await task.value
    }

    private func downloadAndLoadImage(forSide side: String) async throws {
        try await stereoCard.downloadImage(forSide: side)
        try await loadImage(forSide: side)
    }
}

#Preview("StereoCard") {
    AsyncPreviewContainer {
        let card = PreviewContainer.shared.previewCard
        let viewModel = StereoCardViewModel(stereoCard: card)
        return VStack(spacing: 20) {
            HStack {
                Text("Front Image")
                if viewModel.isLoadingFront {
                    ProgressView()
                }
            }

            if let frontImage = viewModel.frontCGImage {
                Image(decorative: frontImage, scale: 1.0)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
            }

            HStack {
                Text("Back Image")
                if viewModel.isLoadingBack {
                    ProgressView()
                }
            }

            if let backImage = viewModel.backCGImage {
                Image(decorative: backImage, scale: 1.0)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
            }
        }
        .padding()
    }
}
