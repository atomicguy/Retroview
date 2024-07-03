//
//  StereoCardView.swift
//  Retroview
//
//  Created by Adam Schuster on 6/30/24.
//

import SwiftUI

@available(visionOS 2.0, *)
struct StereoCardView: View {
    @ObservedObject var viewModel: StereoCardViewModel

    var body: some View {
            if let image = viewModel.frontCGImage {
                #if os(visionOS)
                VisionOSStereoView(viewModel: viewModel)
                #else
                StereoMetalView(
                    cgImage: image,
                    leftEyeRect: viewModel.leftEyeRect,
                    rightEyeRect: viewModel.rightEyeRect
                )
                #endif
            } else {
                Text("Loading...")
            }
        }
}

@available(visionOS 2.0, *)
struct StereoCardViewPreview: PreviewProvider {
    static var previews: some View {
        // Retrieve the first sample stereo card from predefined sample data.
        let sampleCard = CardSchemaV1.StereoCard.sampleData[0]
        
        // Initialize the view model with the sample stereo card.
        let viewModel = StereoCardViewModel(stereoCard: sampleCard)

        // Return the StereoCardView configured with the view model.
        StereoCardView(viewModel: viewModel)
    }
}
