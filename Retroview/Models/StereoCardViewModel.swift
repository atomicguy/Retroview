//
//  StereoCardViewModel.swift
//  Retroview
//
//  Created by Adam Schuster on 6/9/24.
//

import CoreGraphics
import Foundation
import SwiftUI

@MainActor
class StereoCardViewModel: ObservableObject {
    @Published var stereoCard: CardSchemaV1.StereoCard
    @Published var frontCGImage: CGImage?
    @Published var backCGImage: CGImage?
    @Published var isLoadingFront = false
    @Published var isLoadingBack = false
    private var loadingTasks: [String: Task<Void, Error>] = [:]
    
    private let imageLoader: DefaultImageLoader
    
    init(stereoCard: CardSchemaV1.StereoCard, imageLoader: DefaultImageLoader = DefaultImageLoader()) {
        self.stereoCard = stereoCard
        self.imageLoader = imageLoader
    }
    
    func loadImage(forSide side: String) async throws {
        // Cancel any existing loading task for this side
        loadingTasks[side]?.cancel()
        
        let task = Task { @MainActor in
            if side == "front" {
                isLoadingFront = true
                do { isLoadingFront = false }
            } else {
                isLoadingBack = true
                do { isLoadingBack = false }
            }
            
            let imageData = side == "front" ? stereoCard.imageFront : stereoCard.imageBack
            
            if let data = imageData {
                if let cgImage = await imageLoader.createCGImage(from: data) {
                    if side == "front" {
                        frontCGImage = cgImage
                    } else {
                        backCGImage = cgImage
                    }
                } else if let cgImage = await imageLoader.createCGImageAlternative(from: data) {
                    if side == "front" {
                        frontCGImage = cgImage
                    } else {
                        backCGImage = cgImage
                    }
                } else {
                    throw NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to create image"])
                }
            } else {
                try await downloadAndLoadImage(forSide: side)
            }
        }
        
        loadingTasks[side] = task
        try await task.value
    }
    
    private func downloadAndLoadImage(forSide side: String) async throws {
        try await stereoCard.downloadImage(forSide: side)
        try await loadImage(forSide: side)
    }
}

extension StereoCardViewModel {
    static func previewViewModel() async -> StereoCardViewModel {
        let card = await PreviewHelper.shared.previewCard
        return StereoCardViewModel(stereoCard: card)
    }
}

struct PreviewCard<Content: View>: View {
    let content: (StereoCardViewModel) -> Content
    @State private var viewModel: StereoCardViewModel?
    
    init(@ViewBuilder content: @escaping (StereoCardViewModel) -> Content) {
        self.content = content
    }
    
    var body: some View {
        if let viewModel = viewModel {
            content(viewModel)
        } else {
            ProgressView()
                .task {
                    viewModel = await StereoCardViewModel.previewViewModel()
                }
        }
    }
}

#Preview("StereoCard") {
    PreviewCard { viewModel in
        VStack(spacing: 20) {
            HStack {
                Text("Front Image")
                if viewModel.isLoadingFront {
                    ProgressView()
                }
            }

            if let frontImage = viewModel.frontCGImage {
                Image(decorative: frontImage, scale: 1.0)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
            }

            HStack {
                Text("Back Image")
                if viewModel.isLoadingBack {
                    ProgressView()
                }
            }

            if let backImage = viewModel.backCGImage {
                Image(decorative: backImage, scale: 1.0)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
            }
        }
        .padding()
    }
}
