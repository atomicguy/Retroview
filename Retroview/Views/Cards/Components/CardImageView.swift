//
//  CardImageView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/9/24.
//

import SwiftUI

struct CardImageView: View {
    @State private var viewModel: CardViewModel
    let side: CardSide
    
    init(card: CardSchemaV1.StereoCard, side: CardSide) {
        _viewModel = State(initialValue: CardViewModel(card: card))
        self.side = side
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let image = side == .front ? viewModel.frontImage : viewModel.backImage {
                    Image(decorative: image, scale: 1.0)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geometry.size.width)
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .aspectRatio(2/1, contentMode: .fit)
        .task {
            try? await viewModel.loadImage(for: side)
        }
    }
}
