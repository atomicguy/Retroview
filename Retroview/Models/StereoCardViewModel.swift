//
//  StereoCardViewModel.swift
//  Retroview
//
//  Created by Adam Schuster on 6/9/24.
//

import Foundation
import SwiftUI
import CoreGraphics // For CGImage

class StereoCardViewModel: ObservableObject {
    @Published var stereoCard: CardSchemaV1.StereoCard
    @Published var frontCGImage: CGImage?
    @Published var backCGImage: CGImage?

    init(stereoCard: CardSchemaV1.StereoCard) {
        self.stereoCard = stereoCard
    }

    func loadImage(forSide side: String) {
        if side == "front", let data = stereoCard.imageFront {
            frontCGImage = CGImageFromData(data)
        } else if side == "back", let data = stereoCard.imageBack {
            backCGImage = CGImageFromData(data)
        } else {
            // Attempt to download the image if not already loaded
            stereoCard.downloadImage(forSide: side) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success():
                        self.loadImage(forSide: side)
                    case .failure(let error):
                        print("Failed to download image for side \(side): \(error)")
                    }
                }
            }
        }
    }

    private func CGImageFromData(_ data: Data) -> CGImage? {
        #if os(macOS)
        if let nsImage = NSImage(data: data), let imageData = nsImage.tiffRepresentation {
            return NSBitmapImageRep(data: imageData)?.cgImage
        }
        return nil
        #else
        return UIImage(data: data)?.cgImage
        #endif
    }
}
