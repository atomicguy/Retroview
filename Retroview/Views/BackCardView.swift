//
//  BackCardView.swift
//  Retroview
//
//  Created by Adam Schuster on 6/16/24.
//

import SwiftUI

struct BackCardView: View {
    @ObservedObject var viewModel: StereoCardViewModel

    var body: some View {
        StereoCardImageView(viewModel: viewModel, side: "back")
    }
}

#Preview {
    CardPreviewContainer { card in
        BackCardView(viewModel: StereoCardViewModel(stereoCard: card))
            .frame(width: 400, height: 200)
    }
}
