//
//  CardCropView.swift
//  Retroview
//
//  Created by Adam Schuster on 6/17/24.
//

import SwiftUI

struct CardCropView: View {
    @Bindable var card: CardSchemaV1.StereoCard
    @Environment(\.modelContext) private var context
    @StateObject private var viewModel: StereoCardViewModel
    @State private var imageSize: CGSize = .zero
    
    init(card: CardSchemaV1.StereoCard) {
        self.card = card
        _viewModel = StateObject(wrappedValue: StereoCardViewModel(stereoCard: card))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if let frontCGImage = viewModel.frontCGImage {
                    Image(decorative: frontCGImage, scale: 1.0, orientation: .up)
                        .resizable()
                        .scaledToFit()
                        .background(
                            GeometryReader { imageGeometry in
                                Color.clear
                                    .onAppear {
                                        self.imageSize = imageGeometry.size
                                    }
                                    .onChange(of: imageGeometry.size) { oldValue, newValue in
                                        self.imageSize = newValue
                                    }
                            }
                        )
                        .overlay {
                            if imageSize.width > 0 && imageSize.height > 0 {
                                BoundingBoxView(crop: card.leftCrop, color: .red, imageSize: imageSize)
                                BoundingBoxView(crop: card.rightCrop, color: .blue, imageSize: imageSize)
                            }
                        }
                } else {
                    ProgressView("Loading Front Image...")
                }
            }
        }
        .adaptiveFrame()
        .onAppear {
            viewModel.loadImage(forSide: "front")
        }
    }
}

struct BoundingBoxView: View {
    let crop: CropSchemaV1.Crop?
    let color: Color
    let imageSize: CGSize
    
    var body: some View {
        GeometryReader { geometry in
            if let crop = crop {
                // The sample values seem to have x and y flipped
                let width = CGFloat(crop.y1 - crop.y0) * imageSize.width
                let height = CGFloat(crop.x1 - crop.x0) * imageSize.height
                let x = CGFloat(crop.y0) * imageSize.width
                let y = CGFloat(crop.x0) * imageSize.height
                
                Rectangle()
                    .fill(Color.clear)
                    .strokeBorder(color, lineWidth: 5)
                    .frame(width: width, height: height)
                    .position(x: x + width / 2, y: y + height / 2)
            }
        }
    }
}

extension View {
    @ViewBuilder
    func adaptiveFrame() -> some View {
        #if os(visionOS)
        self.frame(width: 800, height: 600)
        #else
        self.frame(minWidth: 400, minHeight: 300)
        #endif
    }
}

#Preview {
    CardCropView(card: SampleData.shared.card)
        .modelContainer(SampleData.shared.modelContainer)
}
