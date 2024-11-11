//
//  FrontBackView.swift
//  Retroview
//
//  Created by Adam Schuster on 6/9/24.
//

import SwiftUI

struct FrontBackView: View {
    @ObservedObject var viewModel: StereoCardViewModel

    var body: some View {
        VStack {
            if let frontCGImage = viewModel.frontCGImage {
                Image(decorative: frontCGImage, scale: 1.0, orientation: .up)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 400, maxHeight: 300)
            } else {
                ProgressView("Loading Front Image...")
                    .onAppear {
                        Task {
                            try? await viewModel.loadImage(forSide: "front")
                        }
                    }
            }

            if let backCGImage = viewModel.backCGImage {
                Image(decorative: backCGImage, scale: 1.0, orientation: .up)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 400, maxHeight: 300)
            } else {
                ProgressView("Loading Back Image...")
                    .onAppear {
                        Task {
                            try? await viewModel.loadImage(forSide: "back")
                        }
                    }
            }
        }
        .padding()
    }
}

struct FrontBackView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleCard = CardSchemaV1.StereoCard.sampleData[0]
        let viewModel = StereoCardViewModel(stereoCard: sampleCard)
        FrontBackView(viewModel: viewModel)
    }
}
