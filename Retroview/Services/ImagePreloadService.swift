//
//  ImagePreloadService.swift
//  Retroview
//
//  Created by Adam Schuster on 12/18/24.
//

import Foundation
import SwiftData

@MainActor
class ImagePreloadService {
    private let urlSession: URLSession
    
    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    func preloadImages(for card: CardSchemaV1.StereoCard) async {
        // Create managers for front and back thumbnails
        let frontManager = CardImageManager(card: card, side: .front, quality: .thumbnail)
        let backManager = CardImageManager(card: card, side: .back, quality: .thumbnail)
        
        // Load front thumbnail
        if let frontURL = frontManager.imageURL {
            do {
                let (data, _) = try await urlSession.data(from: frontURL)
                frontManager.storeImageData(data)
                ImportLogger.log(.info, "Successfully loaded front thumbnail for card: \(card.uuid)")
            } catch {
                ImportLogger.log(.warning, "Failed to load front thumbnail for \(card.uuid): \(error.localizedDescription)")
            }
        }
        
        // Load back thumbnail if available
        if let backURL = backManager.imageURL {
            do {
                let (data, _) = try await urlSession.data(from: backURL)
                backManager.storeImageData(data)
                ImportLogger.log(.info, "Successfully loaded back thumbnail for card: \(card.uuid)")
            } catch {
                ImportLogger.log(.warning, "Failed to load back thumbnail for \(card.uuid): \(error.localizedDescription)")
            }
        }
    }
}
