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

protocol ImageLoading: Sendable {
    func createCGImage(from data: Data) async -> CGImage?
}

struct DefaultImageLoader: ImageLoading {
    func createCGImage(from data: Data) async -> CGImage? {
        #if os(macOS)
            guard let nsImage = NSImage(data: data) else {
                return nil
            }
            
            guard let imageData = nsImage.tiffRepresentation else {
                return nil
            }
            
            guard let imageRep = NSBitmapImageRep(data: imageData) else {
                return nil
            }
            
            return imageRep.cgImage
            
        #else
            guard let uiImage = UIImage(data: data) else {
                return nil
            }
            
            return uiImage.cgImage
        #endif
    }
}

// Alternative implementation using CGImageSource
extension DefaultImageLoader {
    func createCGImageAlternative(from data: Data) async -> CGImage? {
        print(
            "Attempting alternative CGImage creation from data of size: \(data.count) bytes"
        )

        guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil)
        else {
            print("Failed to create CGImageSource")
            return nil
        }
        print("Created CGImageSource")

        let options: [CFString: Any] = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: 2000,
        ]

        guard
            let cgImage = CGImageSourceCreateThumbnailAtIndex(
                imageSource, 0, options as CFDictionary
            )
        else {
            print("Failed to create CGImage from CGImageSource")
            return nil
        }

        print(
            "Successfully created CGImage with size: \(cgImage.width)x\(cgImage.height)"
        )
        return cgImage
    }
}

#if DEBUG
    // Mock image loader for testing purposes
    struct MockImageLoader: ImageLoading {
        var mockImage: CGImage?

        func createCGImage(from _: Data) async -> CGImage? {
            mockImage
        }
    }
#endif
