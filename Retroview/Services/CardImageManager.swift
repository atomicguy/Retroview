//
//  CardImageManager.swift
//  Retroview
//
//  Created by Adam Schuster on 12/18/24.
//

import SwiftUI
import SwiftData

@Observable
class CardImageManager {
    private let card: CardSchemaV1.StereoCard
    private let side: CardSide
    private let quality: ImageQuality
    
    @MainActor
    var storedImage: CGImage? {
        switch (side, quality) {
        case (.front, .thumbnail):
            if let data = card.frontThumbnailData {
                return createCGImage(from: data)
            }
        case (.front, _):
            if let data = card.frontStandardData {
                return createCGImage(from: data)
            }
        case (.back, .thumbnail):
            if let data = card.backThumbnailData {
                return createCGImage(from: data)
            }
        case (.back, _):
            if let data = card.backStandardData {
                return createCGImage(from: data)
            }
        }
        return nil
    }
    
    var imageURL: URL? {
        guard let imageId = side == .front ? card.imageFrontId : card.imageBackId else {
            return nil
        }
        return URL(string: "https://iiif-prod.nypl.org/index.php?id=\(imageId)&t=\(quality.rawValue)")
    }
    
    init(card: CardSchemaV1.StereoCard, side: CardSide, quality: ImageQuality = .standard) {
        self.card = card
        self.side = side
        self.quality = quality
    }
    
    @MainActor
    func storeImageData(_ data: Data) {
        switch (side, quality) {
        case (.front, .thumbnail):
            card.frontThumbnailData = data
        case (.front, _):
            card.frontStandardData = data
        case (.back, .thumbnail):
            card.backThumbnailData = data
        case (.back, _):
            card.backStandardData = data
        }
    }
    
    private func createCGImage(from data: Data) -> CGImage? {
        guard let provider = CGDataProvider(data: data as CFData) else {
            return nil
        }
        return CGImage(
            jpegDataProviderSource: provider,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent
        )
    }
}
