//
//  ImageConversion.swift
//  Retroview
//
//  Created by Adam Schuster on 12/7/24.
//

import Foundation
import ImageIO
import CoreGraphics

enum ImageConversion {
    static func convert(cgImage: CGImage) -> Data? {
        let data = CFDataCreateMutable(kCFAllocatorDefault, 0)
        guard let data = data,
              let destination = CGImageDestinationCreateWithData(
                data,
                "public.jpeg" as CFString,
                1,
                nil
              )
        else {
            return nil
        }
        
        CGImageDestinationAddImage(destination, cgImage, nil)
        
        guard CGImageDestinationFinalize(destination) else {
            return nil
        }
        
        return data as Data
    }
}
