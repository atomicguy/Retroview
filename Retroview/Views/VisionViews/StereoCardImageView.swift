////
////  StereoCardImageView.swift
////  Retroview
////
////  Created by Adam Schuster on 11/18/24.
////
//
//import SwiftUI
//
//struct StereoCardImageView: View {
//    @ObservedObject var viewModel: StereoCardViewModel
//    let side: String
//    let contentMode: ContentMode
//
//    init(
//        viewModel: StereoCardViewModel, side: String,
//        contentMode: ContentMode = .fit
//    ) {
//        self.viewModel = viewModel
//        self.side = side
//        self.contentMode = contentMode
//    }
//
//    var body: some View {
//        GeometryReader { geometry in
//            ZStack {
//                if let image = side == "front"
//                    ? viewModel.frontCGImage : viewModel.backCGImage
//                {
//                    Image(decorative: image, scale: 1.0)
//                        .resizable()
//                        .aspectRatio(contentMode: contentMode)
//                        .frame(
//                            width: geometry.size.width,
//                            height: geometry.size.height
//                        )
//                } else {
//                    Rectangle()
//                        .fill(Color.gray.opacity(0.2))
//                        .overlay {
//                            ProgressView("Loading image...")
//                        }
//                }
//            }
//        }
//        .task {
//            do {
//                try await viewModel.loadImage(forSide: side)
//            } catch {
//                print("Error loading \(side) image: \(error)")
//            }
//        }
//    }
//}
