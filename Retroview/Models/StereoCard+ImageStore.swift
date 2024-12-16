//
//  StereoCard+ImageStore.swift
//  Retroview
//
//  Created by Adam Schuster on 12/15/24.
//

import CoreGraphics

extension CardSchemaV1.StereoCard {
    @MainActor
    func getOrCreateImageStore(for side: CardSide) -> ImageStore {
        // Get ID, defaulting to empty string if nil
        let id = (side == .front ? imageFrontId : imageBackId) ?? ""
        
        // Look for existing store
        if let existing = imageStores.first(where: {
            $0.imageId == id && $0.side == side.rawValue
        }) {
            return existing
        }
        
        // Create new store
        let store = ImageStore(imageId: id, side: side.rawValue)
        imageStores.append(store)
        return store
    }
    
    @MainActor
    func loadImage(for side: CardSide) async throws -> CGImage? {
        guard let imageId = side == .front ? imageFrontId : imageBackId else {
            return nil
        }
        
        // Check the store first
        let store = getOrCreateImageStore(for: side)
        if let data = store.getImageData(),
           let image = await DefaultImageLoader().createCGImage(from: data) {
            return image
        }
        
        // Load and cache image
        let service = ImageServiceFactory.shared.getService()
        let image = try await service.loadImage(id: imageId, side: side)
        
        // Cache the result
        if let data = ImageConversion.convert(cgImage: image) {
            store.setImage(data)
        }
        
        return image
    }
    
    @MainActor
    func loadThumbnail(for side: CardSide) async throws -> CGImage? {
        guard let imageId = side == .front ? imageFrontId : imageBackId else {
            return nil
        }
        
        // Check the store first
        let store = getOrCreateImageStore(for: side)
        if let data = store.getImageData(),
           let image = await DefaultImageLoader().createCGImage(from: data) {
            return image
        }
        
        // Load and cache thumbnail
        let service = ImageServiceFactory.shared.getService()
        let image = try await service.loadThumbnail(
            id: imageId,
            side: side,
            maxSize: 800
        )
        
        // Cache the result
        if let data = ImageConversion.convert(cgImage: image) {
            store.setImage(data)
        }
        
        return image
    }
}
