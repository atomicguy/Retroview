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
    @State private var backgroundColor: Color = .gray.opacity(0.1)

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
                    backgroundColor,
                    backgroundColor.opacity(0.7),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(
            color: backgroundColor.opacity(0.5),
            radius: 8,
            x: 0,
            y: 4
        )
        .task {
            do {
                try await viewModel.loadImage(forSide: "front")
            } catch {
                print("Error loading image: \(error)")
            }
        }
        .onChange(of: viewModel.frontCGImage) { _, newImage in
            if let image = newImage {
                extractBackgroundColor(from: image)
            }
        }
    }

    private func extractBackgroundColor(from image: CGImage) {
        guard let leftCrop = card.leftCrop else { return }

        // Calculate sample region (the visible portion of the image)
        let startX = Int(leftCrop.y0 * Float(image.width))
        let startY = Int(leftCrop.x0 * Float(image.height))
        let sampleWidth = Int((leftCrop.y1 - leftCrop.y0) * Float(image.width))
        let sampleHeight = Int(
            (leftCrop.x1 - leftCrop.x0) * Float(image.height))

        // Create a context for the cropped region
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * sampleWidth
        var pixelData = [UInt8](repeating: 0, count: bytesPerRow * sampleHeight)

        guard
            let context = CGContext(
                data: &pixelData,
                width: sampleWidth,
                height: sampleHeight,
                bitsPerComponent: 8,
                bytesPerRow: bytesPerRow,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            )
        else { return }

        // Draw only the cropped portion
        context.draw(
            image,
            in: CGRect(
                x: Int(-CGFloat(startX)),
                y: Int(-CGFloat(startY)),
                width: image.width,
                height: image.height
            )
        )

        var totalR = 0
        var totalG = 0
        var totalB = 0
        var sampleCount = 0

        // Sample every 10th pixel for performance
        for y in stride(from: 0, to: sampleHeight, by: 10) {
            for x in stride(from: 0, to: sampleWidth, by: 10) {
                let offset = (y * bytesPerRow) + (x * bytesPerPixel)
                guard offset + 2 < pixelData.count else { continue }

                totalR += Int(pixelData[offset])
                totalG += Int(pixelData[offset + 1])
                totalB += Int(pixelData[offset + 2])
                sampleCount += 1
            }
        }

        guard sampleCount > 0 else { return }

        let avgR = Double(totalR) / Double(sampleCount) / 255.0
        let avgG = Double(totalG) / Double(sampleCount) / 255.0
        let avgB = Double(totalB) / Double(sampleCount) / 255.0

        // Enhance the colors
        let saturationMultiplier = 1.5
        let brightnessMultiplier = 1.2

        backgroundColor = Color(
            red: min(avgR * saturationMultiplier * brightnessMultiplier, 1.0),
            green: min(avgG * saturationMultiplier * brightnessMultiplier, 1.0),
            blue: min(avgB * saturationMultiplier * brightnessMultiplier, 1.0)
        )
        .opacity(0.3)  // Increased opacity for more visibility
    }
}

#Preview("Square Crop View") {
    SquareCropView(card: PreviewHelper.shared.previewCard)
        .frame(width: 300)
        .padding()
        .modelContainer(PreviewHelper.shared.modelContainer)
}
