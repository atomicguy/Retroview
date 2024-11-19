//
//  StereoCardView.swift
//  Retroview
//
//  Created by Adam Schuster on 6/9/24.
//

import SwiftUI

struct FrontCardView: View {
    @ObservedObject var viewModel: StereoCardViewModel
    
    var body: some View {
        StereoCardImageView(viewModel: viewModel, side: "front", contentMode: .fill)
    }
}

#Preview {
    FrontCardView(viewModel: StereoCardViewModel(stereoCard: SampleData.shared.card))
        .frame(width: 400, height: 200)
        .modelContainer(SampleData.shared.modelContainer)
}
