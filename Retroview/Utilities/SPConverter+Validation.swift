//
//  SPConverter+Validation.swift
//  Retroview
//
//  Created by Adam Schuster on 12/28/24.
//

import CoreImage

// Extension for Crop Normalization
extension StereoPhotoConverter {
    func validateImageDimensions(_ width: Int, _ height: Int) throws {
        // Check for minimum dimensions
        guard width >= 512 && height >= 512 else {
            throw StereoError.invalidDimensions(
                "Images must be at least 512x512")
        }

        // Check for maximum dimensions
        guard width <= 4096 && height <= 4096 else {
            throw StereoError.invalidDimensions(
                "Images must not exceed 4096x4096")
        }

        // Check for odd dimensions
        if width % 2 != 0 || height % 2 != 0 {
            print("⚠️ Warning: Image dimensions should be even numbers")
        }
    }

    func validateAndNormalizeCrops(
        _ leftImage: CGImage,
        _ rightImage: CGImage
    ) throws -> (left: CGImage, right: CGImage) {
        logger.debug("Validating and normalizing crop dimensions")

        // Ensure both images have valid dimensions
        guard leftImage.width > 0, leftImage.height > 0,
            rightImage.width > 0, rightImage.height > 0
        else {
            logger.error("Invalid image dimensions detected")
            throw StereoError.imageProcessingFailed("Invalid image dimensions detected")
        }

        // Determine the minimum common dimensions
        var targetWidth = min(leftImage.width, rightImage.width)
        var targetHeight = min(leftImage.height, rightImage.height)

        logger.debug(
            "Normalizing crops to dimensions: \(targetWidth)x\(targetHeight)")
        
        targetWidth = (min(leftImage.width, rightImage.width) / 16) * 16
        targetHeight = (min(leftImage.height, rightImage.height) / 16) * 16
        
        logger.debug("Adjusted dimensions to: \(targetWidth)x\(targetHeight)")

        // If dimensions are already identical, return original images
        if leftImage.width == rightImage.width,
            leftImage.height == rightImage.height
        {
            return (left: leftImage, right: rightImage)
        }

        // Create context for resizing crops while maintaining aspect ratio
        guard
            let colorSpaceLeft = leftImage.colorSpace,
            let colorSpaceRight = rightImage.colorSpace,
            let contextLeft = CGContext(
                data: nil,
                width: targetWidth,
                height: targetHeight,
                bitsPerComponent: leftImage.bitsPerComponent,
                bytesPerRow: 0,
                space: colorSpaceLeft,
                bitmapInfo: leftImage.bitmapInfo.rawValue
            ),
            let contextRight = CGContext(
                data: nil,
                width: targetWidth,
                height: targetHeight,
                bitsPerComponent: rightImage.bitsPerComponent,
                bytesPerRow: 0,
                space: colorSpaceRight,
                bitmapInfo: rightImage.bitmapInfo.rawValue
            )
        else {
            logger.error("Failed to create normalization contexts")
            throw StereoError.imageProcessingFailed("Failed to create normalization contexts")
        }

        // Draw scaled images to match target dimensions
        contextLeft.interpolationQuality = .high
        contextLeft.scaleBy(
            x: CGFloat(targetWidth) / CGFloat(leftImage.width),
            y: CGFloat(targetHeight) / CGFloat(leftImage.height))
        contextLeft.draw(
            leftImage,
            in: CGRect(
                x: 0, y: 0,
                width: leftImage.width,
                height: leftImage.height))

        contextRight.interpolationQuality = .high
        contextRight.scaleBy(
            x: CGFloat(targetWidth) / CGFloat(rightImage.width),
            y: CGFloat(targetHeight) / CGFloat(rightImage.height))
        contextRight.draw(
            rightImage,
            in: CGRect(
                x: 0, y: 0,
                width: rightImage.width,
                height: rightImage.height))

        // Extract normalized images
        guard let normalizedLeft = contextLeft.makeImage(),
            let normalizedRight = contextRight.makeImage()
        else {
            logger.error("Failed to create normalized images")
            throw StereoError.imageProcessingFailed("Failed to create normalized images")
        }

        // Use string interpolation with logger's interpolation
        logger.debug(
            "Normalized crop dimensions: Left \(normalizedLeft.width)x\(normalizedLeft.height), Right \(normalizedRight.width)x\(normalizedRight.height)"
        )

        return (left: normalizedLeft, right: normalizedRight)
    }
}
