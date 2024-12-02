//
//  CroppedCardView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/1/24.
//

import SwiftData
import SwiftUI

struct CroppedCardView: View {
    @Bindable var card: CardSchemaV1.StereoCard
    @StateObject private var viewModel: StereoCardViewModel

    init(card: CardSchemaV1.StereoCard) {
        self.card = card
        _viewModel = StateObject(wrappedValue: StereoCardViewModel(stereoCard: card))
    }

    var displayTitle: String {
        card.titlePick?.text ?? card.titles.first?.text ?? "Untitled"
    }

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            GeometryReader { geometry in
                if let image = viewModel.frontCGImage,
                   let leftCrop = card.leftCrop
                {
                    let cropWidth = CGFloat(leftCrop.y1 - leftCrop.y0)
                    let cropHeight = CGFloat(leftCrop.x1 - leftCrop.x0)
                    let scale = min(
                        geometry.size.width / (cropWidth * CGFloat(image.width)),
                        geometry.size.height / (cropHeight * CGFloat(image.height))
                    )

                    Image(decorative: image, scale: 1.0)
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: CGFloat(image.width) * scale,
                            height: CGFloat(image.height) * scale
                        )
                        .offset(
                            x: -CGFloat(leftCrop.y0) * CGFloat(image.width) * scale,
                            y: -CGFloat(leftCrop.x0) * CGFloat(image.height) * scale
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(displayTitle)
                .font(.system(.subheadline, design: .serif))
                .lineLimit(2)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            LinearGradient(
                colors: [
                    card.color,
                    card.color.opacity(card.colorOpacity * 1),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .squareAspectRatio()
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(
            color: card.color.opacity(0.5),
            radius: 8,
            x: 0,
            y: 4
        )
        .task(priority: .high) {
            try? await viewModel.loadImage(forSide: "front")
        }
    }
}

#Preview("Default State") {
    CardPreviewContainer { card in
        CroppedCardView(card: card)
            .frame(width: 300)
            .padding()
    }
}

#Preview("Loading State") {
    CardPreviewContainer { _ in
        let loadingCard = CardSchemaV1.StereoCard(
            uuid: "test",
            imageFrontId: "nonexistent"
        )
        CroppedCardView(card: loadingCard)
            .frame(width: 300)
            .padding()
    }
}

#Preview("Grid Layout") {
    CardPreviewContainer { card in
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 250, maximum: 300))], spacing: 10) {
            ForEach(0 ..< 4) { _ in
                CroppedCardView(card: card)
            }
        }
        .padding()
    }
}
