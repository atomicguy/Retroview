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
    @Published var frontState = ImageState.initial
    @Published var backState = ImageState.initial

    private let card: CardSchemaV1.StereoCard
    private let imageLoader: ImageLoader

    // Computed properties for easier access
    var frontCGImage: CGImage? { frontState.image }
    var backCGImage: CGImage? { frontState.image }
    var isLoadingFront: Bool { frontState.isLoading }
    var isLoadingBack: Bool { backState.isLoading }

    init(
        stereoCard: CardSchemaV1.StereoCard,
        imageLoader: ImageLoader = ImageLoader()
    ) {
        self.card = stereoCard
        self.imageLoader = imageLoader
    }

    func loadImage(forSide side: String) async throws {
        let currentState = side == "front" ? frontState : backState

        // Skip if already loaded or loading
        if currentState.image != nil || currentState.isLoading {
            return
        }

        // Update loading state
        updateLoadingState(true, for: side)

        do {
            let imageSide = side == "front" ? ImageSide.front : ImageSide.back
            let image = try await imageLoader.loadImage(
                forCard: card, side: imageSide
            )
            updateState(image: image, error: nil, for: side)
        } catch {
            updateState(image: nil, error: error, for: side)
            throw error
        }
    }

    private func updateLoadingState(_ isLoading: Bool, for side: String) {
        if side == "front" {
            frontState.isLoading = isLoading
        } else {
            backState.isLoading = isLoading
        }
    }

    private func updateState(image: CGImage?, error: Error?, for side: String) {
        let newState = ImageState(
            image: image,
            isLoading: false,
            error: error
        )

        if side == "front" {
            frontState = newState
        } else {
            backState = newState
        }
    }
}

// MARK: - Preview Helpers

extension StereoCardViewModel {
    static func previewViewModel() -> StereoCardViewModel {
        StereoCardViewModel(stereoCard: PreviewHelper.shared.previewCard)
    }
}

struct PreviewCard<Content: View>: View {
    let content: (StereoCardViewModel) -> Content
    @State private var viewModel: StereoCardViewModel?

    init(@ViewBuilder content: @escaping (StereoCardViewModel) -> Content) {
        self.content = content
    }

    var body: some View {
        if let viewModel = viewModel {
            content(viewModel)
        } else {
            ProgressView()
                .task {
                    viewModel = StereoCardViewModel.previewViewModel()
                }
        }
    }
}

#Preview("StereoCard") {
    PreviewCard { viewModel in
        VStack(spacing: 20) {
            HStack {
                Text("Front Image")
                if viewModel.isLoadingFront {
                    ProgressView()
                }
            }

            if let frontImage = viewModel.frontCGImage {
                Image(decorative: frontImage, scale: 1.0)
                    .resizable()
                    .scaledToFit()
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
                    .scaledToFit()
                    .frame(height: 200)
            }
        }
        .padding()
    }
}
