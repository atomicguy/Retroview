//
//  CardSquareView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/9/24.
//

import SwiftUI

struct CardSquareView: View {
    let card: CardSchemaV1.StereoCard
    @State private var viewModel: CardViewModel
    
    init(card: CardSchemaV1.StereoCard) {
        self.card = card
        _viewModel = State(initialValue: CardViewModel(card: card))
    }
    
    var body: some View {
        GeometryReader { geometry in
            if let image = viewModel.frontImage,
               let leftCrop = card.crops.first(where: { $0.side == "left" }) {
                CroppedImageView(
                    image: image,
                    crop: leftCrop,
                    geometry: geometry
                )
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .task {
            try? await viewModel.loadImage(for: .front)
        }
    }
}
