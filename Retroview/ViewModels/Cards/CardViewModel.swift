//
//  CardViewModel.swift
//  Retroview
//
//  Created by Adam Schuster on 12/9/24.
//

import CoreGraphics
import SwiftUI

@Observable final class CardViewModel {
    var card: CardSchemaV1.StereoCard
    private(set) var frontImage: CGImage?
    private(set) var backImage: CGImage?
    private(set) var isLoadingFront = false
    private(set) var isLoadingBack = false
    private(set) var error: AppError?
    
    init(card: CardSchemaV1.StereoCard) {
        self.card = card
    }
    
    func loadImage(for side: CardSide) async {
        let imageService = await ImageService.shared()
        
        do {
            if side == .front {
                guard let imageId = card.imageFrontId, !imageId.isEmpty else {
                    throw AppError.invalidData("No front image ID available")
                }
                
                isLoadingFront = true
                defer { isLoadingFront = false }
                
                frontImage = try await imageService.loadImage(
                    id: imageId,
                    side: side
                )
            } else {
                guard let imageId = card.imageBackId, !imageId.isEmpty else {
                    throw AppError.invalidData("No back image ID available")
                }
                
                isLoadingBack = true
                defer { isLoadingBack = false }
                
                backImage = try await imageService.loadImage(
                    id: imageId,
                    side: side
                )
                updateCardColor()
            }
        } catch {
            if let appError = error as? AppError {
                self.error = appError
            } else {
                self.error = AppError.imageLoadFailed(side == .front ? "front" : "back")
            }
        }
    }
    
    private func updateCardColor() {
        if let image = backImage {
            card.cardColor = CardColorAnalyzer.extractCardstockColor(from: image)?.toHex() ?? "#F5E6D3"
        }
    }
    
    func clearError() {
        error = nil
    }
}
