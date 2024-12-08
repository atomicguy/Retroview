//
//  StereoCardViewModel.swift
//  Retroview
//
//  Created by Adam Schuster on 6/9/24.
//

import CoreGraphics
import Foundation
import SwiftUI
import SwiftData

@MainActor
class StereoCardViewModel: ObservableObject {
    @Published var stereoCard: CardSchemaV1.StereoCard
    @Published var frontCGImage: CGImage?
    @Published var backCGImage: CGImage?
    @Published var isLoadingFront = false
    @Published var isLoadingBack = false
    
    private var loadingTasks: [String: Task<Void, Error>] = [:]
    private let imageService: ImageServiceProtocol
    
    init(
        stereoCard: CardSchemaV1.StereoCard,
        imageService: ImageServiceProtocol = ImageServiceFactory.shared.getService()
    ) {
        self.stereoCard = stereoCard
        self.imageService = imageService
    }
    
    func updateCardColor(from image: CGImage) {
        if let newColor = CardColorAnalyzer.extractCardstockColor(from: image) {
            stereoCard.color = newColor
        }
    }
    
    func loadImage(forSide side: String) async throws {
        // Cancel any existing loading task for this side
        loadingTasks[side]?.cancel()
        
        let task = Task {
            if side == "front" {
                isLoadingFront = true
                do { isLoadingFront = false }
            } else {
                isLoadingBack = true
                do { isLoadingBack = false }
            }
            
            let imageData = side == "front" ? stereoCard.imageFront : stereoCard.imageBack
            
            if let data = imageData,
               let cgImage = await DefaultImageLoader().createCGImage(from: data) {
                if side == "front" {
                    frontCGImage = cgImage
                } else {
                    backCGImage = cgImage
                    updateCardColor(from: cgImage)
                }
                return
            }
            
            // If no cached data, load from service
            let cardSide = CardSide(rawValue: side)!
            let imageId = side == "front" ? stereoCard.imageFrontId : stereoCard.imageBackId
            
            guard let id = imageId else { return }
            
            let image = try await imageService.loadImage(id: id, side: cardSide)
            
            if side == "front" {
                frontCGImage = image
            } else {
                backCGImage = image
                updateCardColor(from: image)
            }
        }
        
        loadingTasks[side] = task
        try await task.value
    }
}

// MARK: - Preview Support

#if DEBUG
struct StereoCardViewModelPreview: View {
    @StateObject private var viewModel: StereoCardViewModel
    
    init() {
        let container = try! PreviewDataManager.shared.container()
        let card = try! container.mainContext.fetch(FetchDescriptor<CardSchemaV1.StereoCard>()).first!
        _viewModel = StateObject(wrappedValue: StereoCardViewModel(stereoCard: card))
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Group {
                if viewModel.isLoadingFront {
                    ProgressView("Loading front...")
                } else if let frontImage = viewModel.frontCGImage {
                    Image(decorative: frontImage, scale: 1.0)
                        .resizable()
                        .scaledToFit()
                } else {
                    ContentUnavailableView("No front image", systemImage: "photo")
                }
            }
            .frame(height: 200)
            
            Group {
                if viewModel.isLoadingBack {
                    ProgressView("Loading back...")
                } else if let backImage = viewModel.backCGImage {
                    Image(decorative: backImage, scale: 1.0)
                        .resizable()
                        .scaledToFit()
                } else {
                    ContentUnavailableView("No back image", systemImage: "photo")
                }
            }
            .frame(height: 200)
        }
        .padding()
        .task {
            try? await viewModel.loadImage(forSide: "front")
            try? await viewModel.loadImage(forSide: "back")
        }
    }
}

#Preview("StereoCardViewModel Preview") {
    StereoCardViewModelPreview()
        .withPreviewData()
}
#endif
