//
//  StereoCardState.swift
//  Retroview
//
//  Created by Adam Schuster on 11/20/24.
//

import SwiftUI

@MainActor
class StereoCardState: ObservableObject {
    @Published private(set) var frontState = ImageState.initial
    @Published private(set) var backState = ImageState.initial

    var frontImage: CGImage? { frontState.image }
    var backImage: CGImage? { backState.image }
    var isLoadingFront: Bool { frontState.isLoading }
    var isLoadingBack: Bool { backState.isLoading }

    private let card: CardSchemaV1.StereoCard
    private let imageLoader: ImageLoader

    init(
        card: CardSchemaV1.StereoCard, imageLoader: ImageLoader = ImageLoader()
    ) {
        self.card = card
        self.imageLoader = imageLoader
    }

    func loadImage(side: ImageSide) async {
        let state = side == .front ? frontState : backState

        if state.image != nil || state.isLoading {
            return
        }

        updateLoadingState(true, for: side)

        do {
            let image = try await imageLoader.loadImage(
                forCard: card, side: side
            )
            updateState(image: image, error: nil, for: side)
        } catch {
            updateState(image: nil, error: error, for: side)
        }
    }

    private func updateLoadingState(_ isLoading: Bool, for side: ImageSide) {
        if side == .front {
            frontState.isLoading = isLoading
        } else {
            backState.isLoading = isLoading
        }
    }

    private func updateState(
        image: CGImage?, error: Error?, for side: ImageSide
    ) {
        let newState = ImageState(
            image: image,
            isLoading: false,
            error: error
        )

        if side == .front {
            frontState = newState
        } else {
            backState = newState
        }
    }
}
