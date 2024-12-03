//
//  ThumbnailView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/1/24.
//

import SwiftData
import SwiftUI

struct ThumbnailView: View {
    let card: CardSchemaV1.StereoCard
    @StateObject private var viewModel: StereoCardViewModel

    init(card: CardSchemaV1.StereoCard) {
        self.card = card
        _viewModel = StateObject(wrappedValue: StereoCardViewModel(stereoCard: card))
    }

    var body: some View {
        ZStack {
            if let image = viewModel.frontCGImage {
                Image(decorative: image, scale: 1.0)
                    .resizable()
                    .scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                ProgressView()
            }
        }
        .task {
            try? await viewModel.loadImage(forSide: "front")
        }
    }
}

#Preview {
    CardPreviewContainer { card in
        ThumbnailView(card: card)
            .frame(width: 400, height: 200)
    }
}
