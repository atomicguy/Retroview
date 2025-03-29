//
//  StereoCardSpatialView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/1/24.
//

import SwiftData
import SwiftUI

struct StereoCardSpatialView: View {
    let card: CardSchemaV1.StereoCard
    let currentCollection: CollectionSchemaV1.Collection?

    private static let cornerRadius: CGFloat = 24
    private static let padding: CGFloat = 20
    private static let titleHeight: CGFloat = 64
    private static let materialOpacity: CGFloat = 0.85
    private static let stereoAspectRatio: CGFloat = 1.0 // Square ratio for StereoView

    var displayTitle: String {
        card.titlePick?.text ?? card.titles.first?.text ?? "Untitled"
    }

    var body: some View {
        GeometryReader { geometry in
            let availableHeight = geometry.size.height - Self.titleHeight
            let stereoSize = calculateStereoSize(
                containerWidth: geometry.size.width - (Self.padding * 2),
                containerHeight: availableHeight - (Self.padding * 2)
            )

            ZStack {
                RoundedRectangle(cornerRadius: Self.cornerRadius)
                    .fill(.ultraThickMaterial.opacity(Self.materialOpacity))

                RoundedRectangle(cornerRadius: Self.cornerRadius)
                    .fill(
                        LinearGradient(
                            colors: [card.color, card.color.opacity(card.colorOpacity * 0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                VStack(spacing: 0) {
                    ZStack {
                        Color.red.opacity(0.3)

                        Color.blue.opacity(0.3)
                            .frame(width: stereoSize.width, height: stereoSize.height)

                        StereoView(card: card)
                            .frame(width: stereoSize.width, height: stereoSize.height)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    Text(displayTitle)
                        .font(.system(.headline, design: .serif))
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, Self.padding)
                        .padding(.vertical, Self.padding / 2)
                        .frame(height: Self.titleHeight)
                        .frame(maxWidth: .infinity)
                        .background(.ultraThickMaterial.opacity(Self.materialOpacity))
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: Self.cornerRadius))
        .shadow(color: card.color.opacity(0.3), radius: 12, x: 0, y: 4)
    }

    private func calculateStereoSize(containerWidth: CGFloat, containerHeight: CGFloat) -> CGSize {
        let size = min(containerWidth, containerHeight)
        return CGSize(width: size, height: size)
    }
}

#Preview("Stereo Card Spatial View") {
    CardPreviewContainer { card in
        StereoCardSpatialView(card: card, currentCollection: nil)
            .frame(width: 1000, height: 500)
            .padding()
    }
}
