//
//  SpatialPhotoConverter.swift
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

final class SpatialPhotoConverter {
    private let logger = Logger(
        subsystem: "net.atompowered.retroview",
        category: "SpatialPhotoConverter"
    )

    // Default stereo parameters
    private let parameters = SpatialParameters()

    func createSpatialPhotoData(
        from card: CardSchemaV1.StereoCard, sourceImage: CGImage
    ) async throws -> Data {
        guard let leftCrop = card.leftCrop, let rightCrop = card.rightCrop
        else {
            throw StereoError.missingCropData
        }

        // Process and crop images
        let leftImage = try cropImage(sourceImage, with: leftCrop)
        let rightImage = try cropImage(sourceImage, with: rightCrop)

        // Normalize the crops
        let (normalizedLeft, normalizedRight) = try validateAndNormalizeCrops(
            leftImage, rightImage)

        // Create HEIC data
        return try await createHEICData(
            leftImage: normalizedLeft,
            rightImage: normalizedRight
        )
    }

    private func createHEICData(leftImage: CGImage, rightImage: CGImage)
        async throws -> Data
    {
        let heicData = NSMutableData()

        guard
            let destination = CGImageDestinationCreateWithData(
                heicData,
                "public.heic" as CFString,
                2,
                [kCGImagePropertyPrimaryImage: 0] as CFDictionary
            )
        else {
            throw StereoError.destinationCreationFailed
        }

        // Create image sources
        guard let leftData = try? pngData(from: leftImage),
            let rightData = try? pngData(from: rightImage),
            let leftSource = CGImageSourceCreateWithData(
                leftData as CFData, nil),
            let rightSource = CGImageSourceCreateWithData(
                rightData as CFData, nil)
        else {
            throw StereoError.imageSourceCreationFailed
        }

        // Calculate metadata
        let metadata = try calculateSpatialMetadata(
            width: leftImage.width,
            height: leftImage.height,
            parameters: parameters
        )

        // Add images with metadata
        CGImageDestinationAddImageFromSource(
            destination,
            leftSource,
            0,
            metadata.left as CFDictionary
        )

        CGImageDestinationAddImageFromSource(
            destination,
            rightSource,
            0,
            metadata.right as CFDictionary
        )

        guard CGImageDestinationFinalize(destination) else {
            throw StereoError.finalizationFailed
        }

        return heicData as Data
    }

    private func cropImage(_ source: CGImage, with crop: CropSchemaV1.Crop)
        throws -> CGImage
    {
        try CropUtility.cropImage(source, with: crop)
    }
}
