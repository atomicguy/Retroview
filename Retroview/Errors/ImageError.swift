//
//  ImageError.swift
//  Retroview
//
//  Created by Adam Schuster on 11/20/24.
//

enum ImageError: Error {
    case noData
    case conversionFailed
    case downloadFailed
    case invalidSide

    var localizedDescription: String {
        switch self {
        case .noData:
            return "No image data available"
        case .conversionFailed:
            return "Failed to convert image data"
        case .downloadFailed:
            return "Failed to download image"
        case .invalidSide:
            return "Invalid image side specified"
        }
    }
}
