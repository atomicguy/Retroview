//
//  ThumbnailView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/9/24.
//

import SwiftUI

struct ThumbnailView: View {
    let card: CardSchemaV1.StereoCard
    @State private var viewModel: CardViewModel
    
    init(card: CardSchemaV1.StereoCard) {
        self.card = card
        _viewModel = State(initialValue: CardViewModel(card: card))
    }
    
    var body: some View {
        ZStack {
            if let image = viewModel.frontImage {
                Image(decorative: image, scale: 1.0)
                    .resizable()
                    .scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                ProgressView()
            }
        }
        .task {
            try? await viewModel.loadImage(for: .front)
        }
    }
}
