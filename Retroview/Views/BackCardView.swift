//
//  BackCardView.swift
//  Retroview
//
//  Created by Adam Schuster on 6/16/24.
//

import SwiftData
import SwiftUI

struct BackCardView: View {
    @ObservedObject var viewModel: StereoCardViewModel
    
    init(viewModel: StereoCardViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }

    var body: some View {
        StereoCardImageView(viewModel: viewModel, side: "back")
    }
}

#Preview {
    @Previewable @Query var cards: [CardSchemaV1.StereoCard]
    
    return Group {
        if let card = cards.first {
            BackCardView(viewModel: StereoCardViewModel(stereoCard: card))
                .frame(width: 400, height: 200)
        }
    }
    .withPreviewData()
}
