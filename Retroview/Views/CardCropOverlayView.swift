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
                // Left crop overlay
                if let leftCrop = card.leftCrop {
                    let cropRect = CropUtility.normalizedRect(for: leftCrop)
                    Rectangle()
                        .strokeBorder(Color.red, lineWidth: 4)
                        .frame(
                            width: imageGeometry.size.width * cropRect.width,
                            height: imageGeometry.size.height * cropRect.height
                        )
                        .position(
                            x: imageGeometry.size.width * (cropRect.minX + cropRect.width/2),
                            y: imageGeometry.size.height * (cropRect.minY + cropRect.height/2)
                        )
                }
                
                // Right crop overlay
                if let rightCrop = card.rightCrop {
                    let cropRect = CropUtility.normalizedRect(for: rightCrop)
                    Rectangle()
                        .strokeBorder(Color.blue, lineWidth: 4)
                        .frame(
                            width: imageGeometry.size.width * cropRect.width,
                            height: imageGeometry.size.height * cropRect.height
                        )
                        .position(
                            x: imageGeometry.size.width * (cropRect.minX + cropRect.width/2),
                            y: imageGeometry.size.height * (cropRect.minY + cropRect.height/2)
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
