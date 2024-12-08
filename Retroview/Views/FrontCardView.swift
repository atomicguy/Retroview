//
//  FrontCardView.swift
//  Retroview
//
//  Created by Adam Schuster on 6/9/24.
//

import SwiftData
import SwiftUI

struct FrontCardView: View {
    @ObservedObject var viewModel: StereoCardViewModel

    var body: some View {
        StereoCardImageView(
            viewModel: viewModel, side: "front", contentMode: .fill
        )
    }
}

#Preview {
    @Previewable @Query var cards: [CardSchemaV1.StereoCard]
    
    return Group {
        if let card = cards.first {
            FrontCardView(viewModel: StereoCardViewModel(stereoCard: card))
                .frame(width: 400, height: 200)
        }
    }
    .withPreviewData()
}
