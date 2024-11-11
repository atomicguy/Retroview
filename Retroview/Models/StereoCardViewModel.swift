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

    init(stereoCard: CardSchemaV1.StereoCard) {
        self.stereoCard = stereoCard
        print("ViewModel initialized for card: \(stereoCard.uuid)")
    }

    func loadImage(forSide side: String) async throws {
        print("Loading image for side: \(side)")
        if side == "front", let data = stereoCard.imageFront {
            print("Found front image data")
            frontCGImage = CGImageFromData(data)
            print("Front CGImage created: \(frontCGImage != nil)")
        } else if side == "back", let data = stereoCard.imageBack {
            print("Found back image data")
            backCGImage = CGImageFromData(data)
            print("Back CGImage created: \(backCGImage != nil)")
        } else {
            print("No image data found, attempting download")
            try await downloadImage(forSide: side)
            print("Download successful, reloading image")
            try await loadImage(forSide: side)  // Added 'try' here
        }
    }

    private func downloadImage(forSide side: String) async throws {
        return try await withCheckedThrowingContinuation { continuation in
            stereoCard.downloadImage(forSide: side) { result in
                switch result {
                case .success():
                    continuation.resume()
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    private func CGImageFromData(_ data: Data) -> CGImage? {
        #if os(macOS)
            if let nsImage = NSImage(data: data),
                let imageData = nsImage.tiffRepresentation
            {
                return NSBitmapImageRep(data: imageData)?.cgImage
            }
            return nil
        #else
            return UIImage(data: data)?.cgImage
        #endif
    }
}
