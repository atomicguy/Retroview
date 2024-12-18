//
//  CardImageLoader.swift
//  Retroview
//
//  Created by Adam Schuster on 12/17/24.
//

import SwiftUI

@Observable
final class CardImageLoader: @unchecked Sendable {
    private(set) var thumbnailImage: CGImage?
    private(set) var fullImage: CGImage?
    private(set) var isLoadingThumbnail = false
    private(set) var isLoadingFull = false
    private(set) var loadingError = false
    
    let card: CardSchemaV1.StereoCard
    let side: CardSide
    
    private var loadingTask: Task<Void, Never>?
    
    init(card: CardSchemaV1.StereoCard, side: CardSide) {
        self.card = card
        self.side = side
    }
    
    func loadImages() {
        loadingTask?.cancel()
        loadingTask = Task { @MainActor in
            // Start thumbnail load immediately
            await loadThumbnail()
            
            // Load full image in background
            await loadFullImage()
        }
    }
    
    @MainActor
    private func loadThumbnail() async {
        guard thumbnailImage == nil, !isLoadingThumbnail else { return }
        
        isLoadingThumbnail = true
        do {
            thumbnailImage = try await card.loadImage(side: side, quality: .thumbnail)
        } catch {
            loadingError = true
        }
        isLoadingThumbnail = false
    }
    
    @MainActor
    private func loadFullImage() async {
        guard fullImage == nil, !isLoadingFull else { return }
        
        isLoadingFull = true
        do {
            // Use Task.detached to ensure we're off the main thread
            fullImage = try await Task.detached {
                try await self.card.loadImage(side: self.side, quality: .standard)
            }.value
        } catch {
            loadingError = true
        }
        isLoadingFull = false
    }
    
    func reload() {
        thumbnailImage = nil
        fullImage = nil
        loadingError = false
        loadImages()
    }
    
    deinit {
        loadingTask?.cancel()
    }
}

extension CardSchemaV1.StereoCard {
    func loadImage(side: CardSide, quality: ImageQuality = .standard) async throws -> CGImage {
        let imageId = side == .front ? imageFrontId : imageBackId
        guard let imageId = imageId else {
            throw ImageError.noImageId
        }
        
        // Construct URL directly
        let urlString = "https://iiif-prod.nypl.org/index.php?id=\(imageId)&t=\(quality.rawValue)"
        guard let url = URL(string: urlString) else {
            throw ImageError.invalidURL
        }
        
        // Download data
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // Create image off main thread
        return try await Task.detached {
            guard let provider = CGDataProvider(data: data as CFData),
                  let image = CGImage(
                    jpegDataProviderSource: provider,
                    decode: nil,
                    shouldInterpolate: true,
                    intent: .defaultIntent
                  )
            else {
                throw ImageError.invalidImageData
            }
            return image
        }.value
    }
}

enum ImageError: Error {
    case noImageId
    case invalidURL
    case invalidImageData
}
