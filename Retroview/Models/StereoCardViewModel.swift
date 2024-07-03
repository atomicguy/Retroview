//
//  StereoCardViewModel.swift
//  Retroview
//
//  Created by Adam Schuster on 6/9/24.
//

import Foundation
import SwiftUI
import CoreGraphics

class StereoCardViewModel: ObservableObject {
    @Published var stereoCard: CardSchemaV1.StereoCard
    @Published var frontCGImage: CGImage?
    @Published var backCGImage: CGImage?
    @Published var leftEyeRect: CGRect = .zero
    @Published var rightEyeRect: CGRect = .zero

    init(stereoCard: CardSchemaV1.StereoCard) {
        self.stereoCard = stereoCard
        loadImage(forSide: "front")
        updateCropRects()
    }

    func loadImage(forSide side: String) {
        if side == "front", let data = stereoCard.imageFront {
            frontCGImage = CGImageFromData(data)
            updateCropRects()
        } else if side == "back", let data = stereoCard.imageBack {
            backCGImage = CGImageFromData(data)
        } else {
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

    private func updateCropRects() {
        guard let image = frontCGImage else { return }
        let imageSize = CGSize(width: image.width, height: image.height)
        
        if let leftCrop = stereoCard.leftCrop {
            leftEyeRect = CGRect(
                x: CGFloat(leftCrop.x0),
                y: CGFloat(leftCrop.y0),
                width: CGFloat(leftCrop.x1 - leftCrop.x0),
                height: CGFloat(leftCrop.y1 - leftCrop.y0)
            ).normalized(to: imageSize)
        }
        
        if let rightCrop = stereoCard.rightCrop {
            rightEyeRect = CGRect(
                x: CGFloat(rightCrop.x0),
                y: CGFloat(rightCrop.y0),
                width: CGFloat(rightCrop.x1 - rightCrop.x0),
                height: CGFloat(rightCrop.y1 - rightCrop.y0)
            ).normalized(to: imageSize)
        }
    }
    
    func getCroppedImage(for eye: Eye) -> CGImage? {
        guard let image = frontCGImage else { return nil }
        let rect = eye == .left ? leftEyeRect : rightEyeRect
        let absoluteRect = CGRect(
            x: rect.origin.x * CGFloat(image.width),
            y: rect.origin.y * CGFloat(image.height),
            width: rect.size.width * CGFloat(image.width),
            height: rect.size.height * CGFloat(image.height)
        )
        return image.cropping(to: absoluteRect)
    }
    
    enum Eye {
        case left, right
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

extension CGRect {
    func normalized(to size: CGSize) -> CGRect {
        return CGRect(
            x: self.origin.x / size.width,
            y: self.origin.y / size.height,
            width: self.size.width / size.width,
            height: self.size.height / size.height
        )
    }
}

extension CGImage {
    func cropping(to rect: CGRect) -> CGImage? {
        guard let colorSpace = self.colorSpace else { return nil }
        let context = CGContext(
            data: nil,
            width: Int(rect.width),
            height: Int(rect.height),
            bitsPerComponent: self.bitsPerComponent,
            bytesPerRow: 0,
            space: colorSpace,
            bitmapInfo: self.bitmapInfo.rawValue
        )
        
        context?.draw(self, in: CGRect(x: -rect.origin.x, y: -rect.origin.y, width: CGFloat(self.width), height: CGFloat(self.height)))
        
        return context?.makeImage()
    }
}
