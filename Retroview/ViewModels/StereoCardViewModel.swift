//
//  StereoCardViewModel.swift
//  Retroview
//
//  Created by Adam Schuster on 12/8/24.
//

#if os(iOS) || os(visionOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
import SwiftUI
import SwiftData

@Observable class StereoCardViewModel {
    // MARK: - Properties
    private let card: StereoCard
    private let context: ModelContext
    
    // Image state
    var frontImage: Image?
    var backImage: Image?
    var isLoadingImages = false
    
    // Display state
    var selectedTitle: String {
        card.titles.first ?? "Untitled Card"
    }
    
    var cardColor: Color {
        Color(hex: card.cardColor) ?? .brown
    }
    
    var opacity: Double {
        card.colorOpacity
    }
    
    // MARK: - Initialization
    
    init(card: StereoCard, context: ModelContext) {
        self.card = card
        self.context = context
        Task {
            await loadImages()
        }
    }
    
    // MARK: - Image Loading
    
    @MainActor
    private func loadImages() async {
        guard !isLoadingImages else { return }
        isLoadingImages = true
        
        // Load front image
        if let frontData = card.imageFront {
            frontImage = loadImage(from: frontData)
        }
        
        // Load back image
        if let backData = card.imageBack {
            backImage = loadImage(from: backData)
        }
        
        isLoadingImages = false
    }
    
    private func loadImage(from data: Data) -> Image? {
        #if os(iOS) || os(visionOS)
        guard let uiImage = UIImage(data: data) else { return nil }
        return Image(uiImage: uiImage)
        #elseif os(macOS)
        guard let nsImage = NSImage(data: data) else { return nil }
        return Image(nsImage: nsImage)
        #endif
    }
    
    // MARK: - Metadata Access
    
    var authors: [String] {
        card.authors.map(\.name)
    }
    
    var subjects: [String] {
        card.subjects.map(\.name)
    }
    
    var dates: [String] {
        card.dates.map(\.dateString)
    }
    
    // MARK: - Card Updates
    
    
    func updateOpacity(_ opacity: Double) {
        card.colorOpacity = opacity
        try? context.save()
    }
    
    func updateTitles(_ titles: [String]) {
        card.titles = titles
        try? context.save()
    }
    
    // MARK: - Crop Access
    
    var leftCrop: StereoCrop? {
        card.leftCrop
    }
    
    var rightCrop: StereoCrop? {
        card.rightCrop
    }
    
    func updateCrop(_ crop: StereoCrop, side: StereoCrop.Side) {
        switch side {
        case .left:
            card.leftCrop = crop
        case .right:
            card.rightCrop = crop
        }
        try? context.save()
    }
    
    // MARK: - Collection Management
    
    var collections: [Collection] {
        card.collections
    }
    
    func addToCollection(_ collection: Collection) {
        collection.addCard(card)
        try? context.save()
    }
    
    func removeFromCollection(_ collection: Collection) {
        collection.removeCard(card)
        try? context.save()
    }
}

// MARK: - Error Handling

extension StereoCardViewModel {
    enum CardError: Error {
        case imageLoadingFailed
        case invalidColor
        case saveFailed
        case cropUpdateFailed
    }
}

// MARK: - Image Loading Error Handling

extension StereoCardViewModel {
    struct ImageLoadError: LocalizedError {
        let underlyingError: Error?
        
        var errorDescription: String? {
            "Failed to load image"
        }
        
        var failureReason: String? {
            underlyingError?.localizedDescription
        }
    }
}

extension StereoCardViewModel {
    func updateColor(_ color: Color) {
        if let hexColor = color.toHex() {
            card.cardColor = hexColor
            saveContext()
        } else {
            // Log error or handle invalid color
//            Logger.modelError.error("Failed to convert color to hex")
            card.cardColor = "#F5E6D3" // fallback to default
            saveContext()
        }
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            // Handle error
            print("Error saving context: \(error)")
        }
    }
}


