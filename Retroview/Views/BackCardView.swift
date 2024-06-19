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
        GeometryReader { geometry in
            VStack {
                if let backCGImage = viewModel.backCGImage {
                    Image(decorative: backCGImage, scale: 1.0, orientation: .up)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                } else {
                    ProgressView("Loading Front Image...")
                        .onAppear {
                            viewModel.loadImage(forSide: "back")
                        }
                }
            }
        }
        .padding()
    }
}

struct BackCardView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleCard = CardSchemaV1.StereoCard.sampleData[0]
        let viewModel = StereoCardViewModel(stereoCard: sampleCard)
        FrontCardView(viewModel: viewModel)
    }
}

