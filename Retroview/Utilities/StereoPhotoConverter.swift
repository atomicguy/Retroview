//
//  StereoPhotoConverter.swift
//  Retroview
//
//  Created by Adam Schuster on 12/28/24.
//

import CoreImage
import ImageIO
import OSLog
import UniformTypeIdentifiers

#if os(macOS)
    import AppKit
#else
    import UIKit
#endif

@Observable
final class StereoPhotoConverter {
    let logger = Logger(
        subsystem: "net.atompowered.retroview",
        category: "StereoPhotoConverter"
    )

    // Default stereo parameters - updated for more standard values
    private let defaultBaseline: Double = 63.0  // Standard baseline of 63mm
    private let defaultFOV: Double = 65.0  // Standard FOV for stereo photos
    private let defaultDisparity: Double = 0.035  // 3.5% positive disparity

    func createTemporarySpatialPhoto(
        from card: CardSchemaV1.StereoCard,
        sourceImage: CGImage
    ) async throws -> URL {
        logger.info("Starting spatial photo creation for card: \(card.uuid)")

        guard let leftCrop = card.leftCrop, let rightCrop = card.rightCrop
        else {
            throw StereoError.missingCropData
        }

        // Create temp directory for working files
        let tempDir = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(
            at: tempDir,
            withIntermediateDirectories: true
        )

        // Define working file URLs
        let leftImageURL = tempDir.appendingPathComponent("left.png")
        let rightImageURL = tempDir.appendingPathComponent("right.png")
        let outputURL = tempDir.appendingPathComponent("output.heic")

        // Process and crop images
        let leftImage = try cropImage(sourceImage, with: leftCrop)
        let rightImage = try cropImage(sourceImage, with: rightCrop)

        // Normalize the crops
        let (normalizedLeft, normalizedRight) = try validateAndNormalizeCrops(
            leftImage,
            rightImage
        )

        // Save to temporary files
        try pngData(from: normalizedLeft).write(to: leftImageURL)
        try pngData(from: normalizedRight).write(to: rightImageURL)

        // Create image sources
        guard
            let leftSource = CGImageSourceCreateWithURL(
                leftImageURL as CFURL, nil),
            let rightSource = CGImageSourceCreateWithURL(
                rightImageURL as CFURL, nil)
        else {
            throw StereoError.imageSourceCreationFailed
        }

        // Set up destination
        let destinationProperties: [CFString: Any] = [
            kCGImagePropertyPrimaryImage: 0,
            kCGImageDestinationLossyCompressionQuality: 1.0,
        ]

        guard
            let destination = CGImageDestinationCreateWithURL(
                outputURL as CFURL,
                "public.heic" as CFString,
                2,
                destinationProperties as CFDictionary
            )
        else {
            throw StereoError.destinationCreationFailed
        }

        // Calculate metadata
        let metadata = try calculateSpatialMetadata(
            width: normalizedLeft.width,
            height: normalizedLeft.height,
            baseline: defaultBaseline,
            fov: defaultFOV,
            disparity: defaultDisparity
        )

        // Add images
        CGImageDestinationAddImageFromSource(
            destination,
            leftSource,
            CGImageSourceGetPrimaryImageIndex(leftSource),
            metadata.left as CFDictionary
        )
        CGImageDestinationAddImageFromSource(
            destination,
            rightSource,
            CGImageSourceGetPrimaryImageIndex(rightSource),
            metadata.right as CFDictionary
        )

        // Finalize
        guard CGImageDestinationFinalize(destination) else {
            logger.error(
                "Failed to finalize HEIC with dimensions: \(normalizedLeft.width)x\(normalizedLeft.height)"
            )
            throw StereoError.finalizationFailed
        }

        return outputURL
    }

    // Helper function for CGImage to PNG conversion
    private func pngData(from cgImage: CGImage) throws -> Data {
        #if os(macOS)
            let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
            guard
                let pngData = bitmapRep.representation(
                    using: .png, properties: [:])
            else {
                throw StereoError.imageProcessingFailed
            }
            return pngData
        #else
            // For iOS/visionOS, use UIImage
            let uiImage = UIImage(cgImage: cgImage)
            guard let pngData = uiImage.pngData() else {
                throw StereoError.imageProcessingFailed(
                    "Creating PNG data failed")
            }
            return pngData
        #endif
    }

    // Private helper method for image cropping
    private func cropImage(_ source: CGImage, with crop: CropSchemaV1.Crop)
        throws -> CGImage
    {
        try CropUtility.cropImage(source, with: crop)
    }
}
