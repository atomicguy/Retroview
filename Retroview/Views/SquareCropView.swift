//
//  SquareCropView.swift
//  Retroview
//
//  Created by Adam Schuster on 11/26/24.
//

import CoreGraphics
import SwiftData
import SwiftUI

struct SquareCropView: View {
    @Bindable var card: CardSchemaV1.StereoCard
    @StateObject private var viewModel: StereoCardViewModel

    init(card: CardSchemaV1.StereoCard) {
        self.card = card
        _viewModel = StateObject(
            wrappedValue: StereoCardViewModel(stereoCard: card))
    }

    var displayTitle: String {
        card.titlePick?.text ?? card.titles.first?.text ?? "Untitled"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            GeometryReader { geometry in
                if let image = viewModel.frontCGImage,
                   let leftCrop = card.leftCrop
                {
                    let cropWidth = CGFloat(leftCrop.y1 - leftCrop.y0)
                    let cropHeight = CGFloat(leftCrop.x1 - leftCrop.x0)
                    let scale = min(
                        geometry.size.width
                            / (cropWidth * CGFloat(image.width)),
                        geometry.size.height
                            / (cropHeight * CGFloat(image.height))
                    )

                    Image(decorative: image, scale: 1.0)
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: CGFloat(image.width) * scale,
                            height: CGFloat(image.height) * scale
                        )
                        .offset(
                            x: -CGFloat(leftCrop.y0) * CGFloat(image.width)
                                * scale,
                            y: -CGFloat(leftCrop.x0) * CGFloat(image.height)
                                * scale
                        )
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
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            LinearGradient(
                colors: [
                    card.color,
                    card.color.opacity(card.colorOpacity * 0.7),
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
            // Load both images concurrently
            await withTaskGroup(of: Void.self) { group in
                // Load front image for display
                group.addTask {
                    try? await viewModel.loadImage(forSide: "front")
                }

                // Load back image for color analysis
                group.addTask {
                    try? await viewModel.loadImage(forSide: "back")
                }

                // Wait for all tasks to complete
                await group.waitForAll()
            }
        }
    }
}

#Preview("Square Crop View") {
    CardPreviewContainer { card in
        SquareCropView(card: card)
            .frame(width: 300)
            .padding()
    }
}
