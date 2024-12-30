//
//  SPConverter+Metadata.swift
//  Retroview
//
//  Created by Adam Schuster on 12/28/24.
//

import CoreImage

extension StereoPhotoConverter {
    func calculateSpatialMetadata(
        width: Int,
        height: Int,
        baseline: Double,
        fov: Double,
        disparity: Double
    ) throws -> (left: [CFString: Any], right: [CFString: Any]) {
        // Validate dimensions first
        try validateImageDimensions(width, height)

        // Convert baseline to meters
        let baselineMeters = baseline / 1000.0  // Convert mm to meters

        // Camera positions
        let leftPosition: [Double] = [0, 0, 0]
        let rightPosition: [Double] = [baselineMeters, 0, 0]

        // Calculate intrinsics matrix using standard focal length calculation
        let aspect = Double(height) / Double(width)
        let horizontalFOVRadians = (fov * .pi) / 180.0

        // Calculate focal length ensuring it's reasonable
        let focalLength = Double(width) * 0.5 / tan(horizontalFOVRadians * 0.5)

        // Ensure principal points are centered
        let principalX = Double(width) * 0.5
        let principalY = Double(height) * 0.5

        let intrinsics: [Double] = [
            focalLength, 0, principalX,
            0, focalLength, principalY,
            0, 0, 1,
        ]

        // Use a more conservative disparity adjustment
        let encodedDisparity = Int(disparity * 10000)

        print(
            """
            📊 Metadata Details:
            - Image size: \(width)x\(height) (aspect: \(aspect))
            - Baseline: \(baselineMeters)m
            - FOV: \(fov)°
            - Focal length: \(focalLength)
            - Principal point: (\(principalX), \(principalY))
            - Disparity: \(encodedDisparity) (\(disparity * 100)%)
            """)

        // Create metadata with explicit keys
        let leftMetadata =
            [
                kCGImagePropertyGroups: [
                    kCGImagePropertyGroupIndex: 0,
                    kCGImagePropertyGroupType:
                        kCGImagePropertyGroupTypeStereoPair,
                    kCGImagePropertyGroupImageIsLeftImage: true,
                    kCGImagePropertyGroupImageDisparityAdjustment:
                        encodedDisparity,
                ] as [CFString: Any],
                kCGImagePropertyHEIFDictionary: [
                    kIIOMetadata_CameraExtrinsicsKey: [
                        kIIOCameraExtrinsics_Position: leftPosition,
                        kIIOCameraExtrinsics_Rotation: [
                            1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0,
                        ],
                    ],
                    kIIOMetadata_CameraModelKey: [
                        kIIOCameraModel_Intrinsics: intrinsics,
                        kIIOCameraModel_ModelType:
                            kIIOCameraModelType_SimplifiedPinhole,
                    ],
                ] as [CFString: Any],
                kCGImagePropertyHasAlpha: false,
            ] as [CFString: Any]

        let rightMetadata =
            [
                kCGImagePropertyGroups: [
                    kCGImagePropertyGroupIndex: 0,
                    kCGImagePropertyGroupType:
                        kCGImagePropertyGroupTypeStereoPair,
                    kCGImagePropertyGroupImageIsRightImage: true,
                    kCGImagePropertyGroupImageDisparityAdjustment:
                        encodedDisparity,
                ] as [CFString: Any],
                kCGImagePropertyHEIFDictionary: [
                    kIIOMetadata_CameraExtrinsicsKey: [
                        kIIOCameraExtrinsics_Position: rightPosition,
                        kIIOCameraExtrinsics_Rotation: [
                            1.0, 0.0, 0.0, 0.0, 1.0, 0.0, 0.0, 0.0, 1.0,
                        ],
                    ],
                    kIIOMetadata_CameraModelKey: [
                        kIIOCameraModel_Intrinsics: intrinsics,
                        kIIOCameraModel_ModelType:
                            kIIOCameraModelType_SimplifiedPinhole,
                    ],
                ] as [CFString: Any],
                kCGImagePropertyHasAlpha: false,
            ] as [CFString: Any]

        return (left: leftMetadata, right: rightMetadata)
    }
}
