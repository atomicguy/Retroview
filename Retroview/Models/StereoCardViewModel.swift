//
//  StereoCardViewModel.swift
//  Retroview
//
//  Created by Adam Schuster on 6/9/24.
//

import CoreGraphics  // For CGImage
import Foundation
import SwiftUI

class StereoCardViewModel: ObservableObject {
    @Published var stereoCard: CardSchemaV1.StereoCard
    @Published var frontCGImage: CGImage?
    @Published var backCGImage: CGImage?
    
    private let imageLoader: ImageLoading
    
    init(stereoCard: CardSchemaV1.StereoCard, imageLoader: ImageLoading = DefaultImageLoader()) {
        self.stereoCard = stereoCard
        self.imageLoader = imageLoader
    }
    
    func loadImage(forSide side: String) async throws {
        let imageData = side == "front" ? stereoCard.imageFront : stereoCard.imageBack
        
        if let data = imageData {
            let cgImage = await imageLoader.createCGImage(from: data)
            await MainActor.run {
                if side == "front" {
                    frontCGImage = cgImage
                } else {
                    backCGImage = cgImage
                }
            }
        } else {
            try await downloadAndLoadImage(forSide: side)
        }
    }
    
    private func downloadAndLoadImage(forSide side: String) async throws {
        try await stereoCard.downloadImage(forSide: side)
        try await loadImage(forSide: side)
    }
}
