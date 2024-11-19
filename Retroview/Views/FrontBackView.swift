//
//  FrontBackView.swift
//  Retroview
//
//  Created by Adam Schuster on 6/9/24.
//

import SwiftUI

struct FrontBackView: View {
    var body: some View {
        let viewModel = StereoCardViewModel(stereoCard: SampleData.shared.card)

        VStack(spacing: 20) {
            FrontCardView(viewModel: viewModel)
                .frame(width: 400, height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            BackCardView(viewModel: viewModel)
                .frame(width: 400, height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding()
    }
}

#Preview("Front & Back") {
    FrontBackView()
        .modelContainer(SampleData.shared.modelContainer)
}
