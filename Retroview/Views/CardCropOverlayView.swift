//
//  CardCropOverlayView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/26/24.
//

import SwiftUI
import SwiftData
import OSLog

struct CardCropOverlayView: View {
    let card: CardSchemaV1.StereoCard
    @State private var frontImage: CGImage?
    @State private var isLoading = false
    @State private var loadError: Error?
    
    private let logger = Logger(
        subsystem: "net.atompowered.retroview",
        category: "CardCropOverlay"
    )
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background to ensure something is visible
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                
                // Debug information
                VStack {
                    Text("Card UUID: \(card.uuid.uuidString)")
                    Text("Front Image ID: \(card.imageFrontId ?? "None")")
                    if let leftCrop = card.leftCrop, let rightCrop = card.rightCrop {
                        VStack {
                            Text("Left Crop: x0:\(leftCrop.x0, specifier: "%.2f"), y0:\(leftCrop.y0, specifier: "%.2f"), x1:\(leftCrop.x1, specifier: "%.2f"), y1:\(leftCrop.y1, specifier: "%.2f")")
                            Text("Right Crop: x0:\(rightCrop.x0, specifier: "%.2f"), y0:\(rightCrop.y0, specifier: "%.2f"), x1:\(rightCrop.x1, specifier: "%.2f"), y1:\(rightCrop.y1, specifier: "%.2f")")
                        }
                    }
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                
                // Image loading states
                if isLoading {
                    ProgressView()
                } else if let loadError {
                    Text("Error: \(loadError.localizedDescription)")
                        .foregroundStyle(.red)
                }
                
                // Display the front image
                if let image = frontImage {
                    Image(decorative: image, scale: 1.0)
                        .resizable()
                        .scaledToFit()
                        .overlay {
                            cropOverlayLayer(geometry: geometry)
                        }
                }
            }
        }
        .task {
            await loadFrontImage()
        }
    }
    
    private func loadFrontImage() async {
        let imageLoader = CardImageLoader()
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let loadedImage = try await imageLoader.loadImage(
                for: card,
                side: .front,
                quality: .standard
            )
            
            logger.debug("Image loaded successfully for card \(self.card.uuid)")
            
            await MainActor.run {
                self.frontImage = loadedImage
            }
        } catch {
            logger.error("Failed to load image: \(error.localizedDescription)")
            loadError = error
        }
    }
    
    private func cropOverlayLayer(geometry: GeometryProxy) -> some View {
        GeometryReader { imageGeometry in
            ZStack(alignment: .center) {
                // Ensure crops are constrained to image bounds
                // Left crop overlay
                if let leftCrop = card.leftCrop {
                    Rectangle()
                        .strokeBorder(Color.red, lineWidth: 4)
                        .frame(
                            width: imageGeometry.size.width * CGFloat(min(leftCrop.x1, 1.0) - max(leftCrop.x0, 0.0)),
                            height: imageGeometry.size.height * CGFloat(min(leftCrop.y1, 1.0) - max(leftCrop.y0, 0.0))
                        )
                        .position(
                            x: imageGeometry.size.width * CGFloat((max(leftCrop.x0, 0.0) + min(leftCrop.x1, 1.0)) / 2),
                            y: imageGeometry.size.height * CGFloat((max(leftCrop.y0, 0.0) + min(leftCrop.y1, 1.0)) / 2)
                        )
                }
                
                // Right crop overlay
                if let rightCrop = card.rightCrop {
                    Rectangle()
                        .strokeBorder(Color.blue, lineWidth: 4)
                        .frame(
                            width: imageGeometry.size.width * CGFloat(min(rightCrop.x1, 1.0) - max(rightCrop.x0, 0.0)),
                            height: imageGeometry.size.height * CGFloat(min(rightCrop.y1, 1.0) - max(rightCrop.y0, 0.0))
                        )
                        .position(
                            x: imageGeometry.size.width * CGFloat((max(rightCrop.x0, 0.0) + min(rightCrop.x1, 1.0)) / 2),
                            y: imageGeometry.size.height * CGFloat((max(rightCrop.y0, 0.0) + min(rightCrop.y1, 1.0)) / 2)
                        )
                }
            }
        }
    }
}

#Preview("Card Crop Overlay") {
    CardCropOverlayView(card: PreviewDataManager.shared.singleCard()!)
        .withPreviewStore()
        .frame(width: 800, height: 600)
}

#Preview("Filtered Card") {
    CardCropOverlayView(card: PreviewDataManager.shared.singleCard { card in
        card.imageFrontId != nil && card.leftCrop != nil
    }!)
    .withPreviewStore()
}
