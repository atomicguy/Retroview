//
//  CardColorAnalyzer.swift
//  Retroview
//
//  Created by Adam Schuster on 11/27/24.
//

import SwiftData
import CoreGraphics
import SwiftUI

#if os(macOS)
    import AppKit
#else
    import UIKit
#endif

enum CardColorAnalyzer {
    static func extractCardstockColor(
        from image: CGImage,
        opacity: Double = 0.15
    ) -> Color? {
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * image.width
        var pixelData = [UInt8](repeating: 0, count: bytesPerRow * image.height)

        guard
            let context = CGContext(
                data: &pixelData,
                width: image.width,
                height: image.height,
                bitsPerComponent: 8,
                bytesPerRow: bytesPerRow,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            )
        else { return nil }

        context.draw(
            image,
            in: CGRect(x: 0, y: 0, width: image.width, height: image.height)
        )

        let startX = image.width / 3
        let endX = (image.width * 2) / 3
        let startY = image.height / 3
        let endY = (image.height * 2) / 3

        var totalR = 0
        var totalG = 0
        var totalB = 0
        var sampleCount = 0

        for y in stride(from: startY, to: endY, by: 5) {
            for x in stride(from: startX, to: endX, by: 5) {
                let offset = (y * bytesPerRow) + (x * bytesPerPixel)
                guard offset + 2 < pixelData.count else { continue }

                totalR += Int(pixelData[offset])
                totalG += Int(pixelData[offset + 1])
                totalB += Int(pixelData[offset + 2])
                sampleCount += 1
            }
        }

        guard sampleCount > 0 else { return nil }

        return Color(
            red: Double(totalR) / Double(sampleCount) / 255.0,
            green: Double(totalG) / Double(sampleCount) / 255.0,
            blue: Double(totalB) / Double(sampleCount) / 255.0
        ).opacity(opacity)
    }
}

struct CardColorAnalyzerPreview: View {
    @State private var extractedColor: Color?
    @State private var baseColor: Color?
    @State private var opacity: Double = 0.20
    @StateObject private var viewModel: StereoCardViewModel

    init() {
        let container = try! PreviewDataManager.shared.container()
        let card = try! container.mainContext.fetch(FetchDescriptor<CardSchemaV1.StereoCard>()).first!
        _viewModel = StateObject(wrappedValue: StereoCardViewModel(stereoCard: card))
    }


    var body: some View {
        VStack(spacing: 20) {
            Text("Card Color Analyzer Preview")
                .font(.title)

            if let backImage = viewModel.backCGImage {
                VStack(spacing: 8) {
                    Text("Original Back Image")
                        .font(.headline)

                    Image(decorative: backImage, scale: 1.0)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 200)
                        .border(Color.gray)
                        .overlay(
                            Rectangle()
                                .strokeBorder(Color.yellow, lineWidth: 2)
                                .frame(
                                    width: CGFloat(backImage.width) / 3,
                                    height: CGFloat(backImage.height) / 3
                                )
                        )
                }

                VStack(spacing: 8) {
                    Text("Extracted Color Sample")
                        .font(.headline)

                    if let baseColor {
                        VStack(spacing: 12) {
                            Rectangle()
                                .fill(baseColor.opacity(opacity))
                                .frame(width: 200, height: 100)
                                .border(Color.gray)

                            HStack {
                                Text("Opacity:")
                                Slider(value: $opacity, in: 0.05 ... 1.0) {
                                    Text("Opacity")
                                }
                                Text(String(format: "%.2f", opacity))
                                    .monospacedDigit()
                                    .frame(width: 40, alignment: .trailing)
                            }
                            .frame(width: 300)

                            Text("RGB: \(baseColor.description)")
                                .font(.caption)
                        }
                    } else {
                        Text("No color extracted")
                            .foregroundStyle(.secondary)
                    }
                }

                // Sample content preview
                VStack(spacing: 8) {
                    Text("Sample Content Background")
                        .font(.headline)

                    if let color = baseColor {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Sample Title")
                                    .font(.title)
                                Text(
                                    "This is some sample content to show how the background color looks with actual text and content overlaid. The opacity slider above can help find the right balance between visibility and readability."
                                )
                                .multilineTextAlignment(.leading)
                            }
                            .padding()
                            .frame(width: 300)
                        }
                        .background(color.opacity(opacity))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            } else {
                ProgressView("Loading image...")
            }
        }
        .padding()
        .task {
            do {
                try await viewModel.loadImage(forSide: "back")
                if let backImage = viewModel.backCGImage {
                    // Store the base color without opacity
                    baseColor = CardColorAnalyzer.extractCardstockColor(
                        from: backImage, opacity: 1.0
                    )
                }
            } catch {
                print("Error loading image: \(error)")
            }
        }
    }
}

#Preview("Card Color Analyzer") {
    CardColorAnalyzerPreview()
        .withPreviewData()
        .frame(width: 600, height: 900)
}
