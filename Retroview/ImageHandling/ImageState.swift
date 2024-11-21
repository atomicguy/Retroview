//
//  ImageState.swift
//  Retroview
//
//  Created by Adam Schuster on 11/20/24.
//

import CoreGraphics
import Foundation

struct ImageState {
    var image: CGImage?
    var isLoading: Bool
    var error: Error?

    static var initial: ImageState {
        ImageState(image: nil, isLoading: false, error: nil)
    }
}
