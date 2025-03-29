//
//  StereoErrors.swift
//  Retroview
//
//  Created by Adam Schuster on 12/28/24.
//

import Foundation

enum StereoError: LocalizedError {
    case missingImageLoader
    case imageLoadFailed
    case missingRequiredData
    case missingCropData
    case imageSourceCreationFailed
    case destinationCreationFailed
    case finalizationFailed
    case missingDependencies
    case invalidDimensions(String)
    case imageProcessingFailed(String)

    var errorDescription: String? {
        switch self {
        case .missingImageLoader:
            return "Image loader not available"
        case .imageLoadFailed:
            return "Failed to load stereo image"
        case .missingRequiredData:
            return "Missing required data"
        case .missingCropData:
            return "Missing crop data for stereo card"
        case .imageSourceCreationFailed:
            return "Failed to create image source"
        case .destinationCreationFailed:
            return "Failed to create HEIC destination"
        case .finalizationFailed:
            return "Failed to finalize spatial photo"
        case .missingDependencies:
            return "Required services are not available for sharing"
        case .invalidDimensions(let reason):
            return "Invalid image dimensions: \(reason)"
        case .imageProcessingFailed(let reason):
            return "Failed to process image: \(reason)"
        }
    }
}
