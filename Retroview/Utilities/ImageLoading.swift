//
//  ImageLoading.swift
//  Retroview
//
//  Created by Adam Schuster on 11/10/24.
//

import CoreGraphics
import Foundation

#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// Protocol defining image loading operations
protocol ImageLoading {
    /// Creates a CGImage from raw image data
    /// - Parameter data: The raw image data
    /// - Returns: An optional CGImage
    func createCGImage(from data: Data) async -> CGImage?
}

/// Default implementation of ImageLoading protocol
struct DefaultImageLoader: ImageLoading {
    func createCGImage(from data: Data) async -> CGImage? {
        #if os(macOS)
        guard let nsImage = NSImage(data: data),
              let imageData = nsImage.tiffRepresentation,
              let cgImage = NSBitmapImageRep(data: imageData)?.cgImage
        else {
            return nil
        }
        return cgImage
        #else
        return UIImage(data: data)?.cgImage
        #endif
    }
}

// MARK: - Testing Support

#if DEBUG
/// Mock image loader for testing purposes
struct MockImageLoader: ImageLoading {
    var mockImage: CGImage?

    func createCGImage(from data: Data) async -> CGImage? {
        return mockImage
    }
}
#endif
