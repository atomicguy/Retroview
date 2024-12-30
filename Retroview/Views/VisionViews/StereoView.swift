//
//  StereoView.swift
//  Retroview
//
//  Created by Adam Schuster on 10/20/24.

import SwiftData
import SwiftUI
import OSLog

#if os(visionOS)
    import RealityKit
    import StereoViewer

    struct StereoView: View {
        let card: CardSchemaV1.StereoCard
        @Environment(\.dismiss) private var dismiss
        @Environment(\.imageLoader) private var imageLoader
        @StateObject private var coordinator = StereoViewCoordinator()
        @StateObject private var materialLoader = StereoMaterialLoader()
        
        private let logger = Logger(
            subsystem: "com.example.retroview",
            category: "StereoView"
        )
        
        @State private var content: RealityViewContent?
        @State private var frontImage: CGImage?
        @State private var isReady = false
        @State private var loadError: Error?

        var body: some View {
            GeometryReader { geometry in
                ZStack {
                    if isReady {
                        mainView(geometry: geometry)
                            .transition(.opacity)
                    } else {
                        loadingView
                            .transition(.opacity)
                    }
                }
                .animation(.smooth, value: isReady)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .task {
                await loadContent()
            }
            .onAppear {
                // Log initial state
                logger.debug("StereoView appeared for card: \(card.uuid)")
                logger.debug("Front image ID: \(card.imageFrontId ?? "nil")")
                logger.debug("Has left crop: \(card.leftCrop != nil)")
                logger.debug("Has right crop: \(card.rightCrop != nil)")
            }
            .background(.clear)
        }

        private func loadContent() async {
            logger.debug("Starting content load sequence")
            
            // Load material first
            logger.debug("Loading stereo material...")
            await materialLoader.loadMaterial()
            
            switch materialLoader.status {
            case .success:
                logger.debug("Material loaded successfully")
                coordinator.stereoMaterial = materialLoader.material
            case .loading:
                logger.debug("Material still loading (unexpected state)")
            case .error(let error):
                logger.error("Material loading failed: \(error.localizedDescription)")
                loadError = error
                return
            }
            
            // Then load image
            do {
                logger.debug("Loading front image...")
                guard let imageLoader = imageLoader else {
                    logger.error("No image loader available in environment")
                    throw StereoError.missingImageLoader
                }
                
                frontImage = try await imageLoader.loadImage(
                    for: card,
                    side: .front,
                    quality: .high
                )
                
                if frontImage != nil {
                    logger.debug("Front image loaded successfully")
                    withAnimation {
                        isReady = true
                    }
                } else {
                    logger.error("Front image loaded but was nil")
                    throw StereoError.imageLoadFailed
                }
            } catch {
                logger.error("Image loading failed: \(error.localizedDescription)")
                loadError = error
            }
        }

        private func mainView(geometry: GeometryProxy) -> some View {
            RealityView { content in
                logger.debug("RealityView initial setup")
                self.content = content
            } update: { content in
                logger.debug("RealityView update called")
                let contentCopy = content
                
                Task { @MainActor in
                    guard let image = frontImage else {
                        logger.error("No front image available for RealityView update")
                        return
                    }
                    
                    guard let leftCrop = card.leftCrop else {
                        logger.error("No left crop data available")
                        return
                    }
                    
                    guard let rightCrop = card.rightCrop else {
                        logger.error("No right crop data available")
                        return
                    }
                    
                    do {
                        logger.debug("Updating RealityView content...")
                        try await coordinator.updateContent(
                            content: contentCopy,
                            sourceImage: image,
                            leftCrop: leftCrop,
                            rightCrop: rightCrop
                        )
                        logger.debug("RealityView content updated successfully")
                    } catch {
                        logger.error("RealityView update failed: \(error.localizedDescription)")
                        loadError = error
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }

        private var loadingView: some View {
            VStack(spacing: 16) {
                if let error = loadError {
                    Label(error.localizedDescription, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.red)
                } else {
                    ProgressView()
                        .controlSize(.large)
                    Text("Loading stereo view...")
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

// MARK: - Preview Support
#Preview("Stereo View") {
    let descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
    let container = try! PreviewDataManager.shared.container()
    let card = try! container.mainContext.fetch(descriptor).first!
    
    return StereoView(card: card)
        .withPreviewStore()
        .environment(\.imageLoader, CardImageLoader())  // Add image loader
}

#Preview("Stereo View with Specific Card") {
    // Find a card with front image and crops
    StereoView(card: PreviewDataManager.shared.singleCard { card in
        card.imageFrontId != nil && card.leftCrop != nil
    }!)
    .withPreviewStore()
    .environment(\.imageLoader, CardImageLoader())  // Add image loader
}

#endif
