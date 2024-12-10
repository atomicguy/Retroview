//
//  ImageLoading.swift
//  Retroview
//
//  Created by Adam Schuster on 12/9/24.
//

import CoreGraphics
import AppKit

protocol ImageLoading {
    func createCGImage(from data: Data) async -> CGImage?
}

struct DefaultImageLoader: ImageLoading {
    func createCGImage(from data: Data) async -> CGImage? {
        #if os(macOS)
        guard let nsImage = NSImage(data: data),
              let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return nil
        }
        return cgImage
        #else
        guard let uiImage = UIImage(data: data) else {
            return nil
        }
        return uiImage.cgImage
        #endif
    }
}
