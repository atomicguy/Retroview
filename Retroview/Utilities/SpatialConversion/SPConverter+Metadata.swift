//
//  SPConverter+Metadata.swift
//  Retroview
//
//  Created by Adam Schuster on 12/28/24.
//

import CoreImage

extension SpatialPhotoConverter {
    struct SpatialParameters {
        let baseline: Double = 63.0  // Standard baseline in mm
        let fov: Double = 65.0  // Standard FOV
        let disparity: Double = 0.035  // 3.5% positive disparity
    }

    func calculateSpatialMetadata(
        width: Int,
        height: Int,
        parameters: SpatialParameters
    ) throws -> (left: [CFString: Any], right: [CFString: Any]) {
        try validateImageDimensions(width, height)

        // Convert baseline to meters
        let baselineMeters = parameters.baseline / 1000.0

        // Camera positions
        let leftPosition: [Double] = [0, 0, 0]
        let rightPosition: [Double] = [baselineMeters, 0, 0]

        // Calculate intrinsics
        let horizontalFOVRadians = (parameters.fov * .pi) / 180.0
        let focalLength = Double(width) * 0.5 / tan(horizontalFOVRadians * 0.5)
        let principalX = Double(width) * 0.5
        let principalY = Double(height) * 0.5

        let intrinsics: [Double] = [
            focalLength, 0, principalX,
            0, focalLength, principalY,
            0, 0, 1,
        ]

        let encodedDisparity = Int(parameters.disparity * 10000)

        // Create metadata dictionaries
        return (
            left: createMetadataDictionary(
                position: leftPosition,
                intrinsics: intrinsics,
                disparity: encodedDisparity,
                isLeft: true
            ),
            right: createMetadataDictionary(
                position: rightPosition,
                intrinsics: intrinsics,
                disparity: encodedDisparity,
                isLeft: false
            )
        )
    }

    private func createMetadataDictionary(
        position: [Double],
        intrinsics: [Double],
        disparity: Int,
        isLeft: Bool
    ) -> [CFString: Any] {
        [
            kCGImagePropertyGroups: [
                kCGImagePropertyGroupIndex: 0,
                kCGImagePropertyGroupType: kCGImagePropertyGroupTypeStereoPair,
                isLeft
                    ? kCGImagePropertyGroupImageIsLeftImage
                    : kCGImagePropertyGroupImageIsRightImage: true,
                kCGImagePropertyGroupImageDisparityAdjustment: disparity,
            ],
            kCGImagePropertyHEIFDictionary: [
                kIIOMetadata_CameraExtrinsicsKey: [
                    kIIOCameraExtrinsics_Position: position,
                    kIIOCameraExtrinsics_Rotation: [
                        1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0,
                    ],
                ],
                kIIOMetadata_CameraModelKey: [
                    kIIOCameraModel_Intrinsics: intrinsics,
                    kIIOCameraModel_ModelType:
                        kIIOCameraModelType_SimplifiedPinhole,
                ],
            ],
            kCGImagePropertyHasAlpha: false,
        ]
    }
}
