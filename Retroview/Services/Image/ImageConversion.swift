//
//  ImageConversion.swift
//  Retroview
//
//  Created by Assistant on 12/9/24.
//

import CoreGraphics
import Foundation
import AppKit

enum ImageConversion {
    static func convert(cgImage: CGImage) -> Data? {
        #if os(macOS)
        let bitmap = NSBitmapImageRep(cgImage: cgImage)
        return bitmap.representation(using: .jpeg, properties: [:])
        #else
        let uiImage = UIImage(cgImage: cgImage)
        return uiImage.jpegData(compressionQuality: 0.8)
        #endif
    }
}
