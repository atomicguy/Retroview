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
    
    init(card: CardSchemaV1.StereoCard) {
        self.card = card
    }
    
    func loadImage(for side: CardSide) async throws {
        let imageService = await ImageService.shared()
        
        if side == .front {
            isLoadingFront = true
            defer { isLoadingFront = false }
            
            frontImage = try await imageService.loadImage(
                id: card.imageFrontId ?? "",
                side: side
            )
        } else {
            isLoadingBack = true
            defer { isLoadingBack = false }
            
            backImage = try await imageService.loadImage(
                id: card.imageBackId ?? "",
                side: side
            )
            updateCardColor()
        }
    }
    
    private func updateCardColor() {
        if let image = backImage {
            card.cardColor = CardColorAnalyzer.extractCardstockColor(from: image)?.toHex() ?? "#F5E6D3"
        }
    }
}
