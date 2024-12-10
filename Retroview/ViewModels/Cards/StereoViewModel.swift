//
//  StereoViewModel.swift
//  Retroview
//
//  Created by Adam Schuster on 12/9/24.
//

import SwiftUI

@Observable final class StereoViewModel {
    var card: CardSchemaV1.StereoCard
    private(set) var cardImage: CGImage?
    private(set) var isLoading = false
    
    init(card: CardSchemaV1.StereoCard) {
        self.card = card
    }
    
    func loadStereoImage() async throws {
        let imageService = await ImageService.shared()
        
        isLoading = true
        defer { isLoading = false }
        
        cardImage = try await imageService.loadImage(
            id: card.imageFrontId ?? "",
            side: .front
        )
    }
}
