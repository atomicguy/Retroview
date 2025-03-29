//
//  SPConverter+Validation.swift
//  Retroview
//
//  Created by Adam Schuster on 12/28/24.
//

import CoreImage
import SwiftUI

// Extension for Crop Normalization
extension SpatialPhotoConverter {
    func validateImageDimensions(_ width: Int, _ height: Int) throws {
        guard width >= 512 && height >= 512 else {
            throw StereoError.invalidDimensions(
                "Images must be at least 512x512")
        }

        guard width <= 4096 && height <= 4096 else {
            throw StereoError.invalidDimensions(
                "Images must not exceed 4096x4096")
        }
    }

    func validateAndNormalizeCrops(_ leftImage: CGImage, _ rightImage: CGImage)
        throws -> (left: CGImage, right: CGImage)
    {
        guard leftImage.width > 0, leftImage.height > 0,
            rightImage.width > 0, rightImage.height > 0
        else {
            throw StereoError.imageProcessingFailed("Invalid image dimensions")
        }

        // Ensure dimensions are multiples of 16 for optimal processing
        let targetWidth = (min(leftImage.width, rightImage.width) / 16) * 16
        let targetHeight = (min(leftImage.height, rightImage.height) / 16) * 16

        // If dimensions are already identical and valid, return originals
        if leftImage.width == rightImage.width,
            leftImage.height == rightImage.height,
            leftImage.width == targetWidth,
            leftImage.height == targetHeight
        {
            return (left: leftImage, right: rightImage)
        }

        // Otherwise normalize both images
        return try (
            left: normalizeImage(
                leftImage, to: CGSize(width: targetWidth, height: targetHeight)),
            right: normalizeImage(
                rightImage, to: CGSize(width: targetWidth, height: targetHeight)
            )
        )
    }

    private func normalizeImage(_ image: CGImage, to size: CGSize) throws
        -> CGImage
    {
        guard
            let context = CGContext(
                data: nil,
                width: Int(size.width),
                height: Int(size.height),
                bitsPerComponent: image.bitsPerComponent,
                bytesPerRow: 0,
                space: image.colorSpace ?? CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: image.bitmapInfo.rawValue
            )
        else {
            throw StereoError.imageProcessingFailed(
                "Failed to create context for normalization")
        }

        context.interpolationQuality = .high
        context.draw(
            image,
            in: CGRect(origin: .zero, size: size)
        )

        guard let normalizedImage = context.makeImage() else {
            throw StereoError.imageProcessingFailed(
                "Failed to create normalized image")
        }

        return normalizedImage
    }

    func pngData(from cgImage: CGImage) throws -> Data {
        #if os(macOS)
            let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
            guard
                let pngData = bitmapRep.representation(
                    using: .png, properties: [:])
            else {
                throw StereoError.imageProcessingFailed("PNG conversion failed")
            }
            return pngData
        #else
            let uiImage = UIImage(cgImage: cgImage)
            guard let pngData = uiImage.pngData() else {
                throw StereoError.imageProcessingFailed("PNG conversion failed")
            }
            return pngData
        #endif
    }
}
