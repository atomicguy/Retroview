//
//  ImageQuality.swift
//  Retroview
//
//  Created by Adam Schuster on 12/16/24.
//

enum ImageQuality: String {
    case thumbnail = "f"  // 140px
    case standard = "w"   // 760px
    case high = "q"      // 1600px
    case ultra = "v"     // 2560px
    case original = "g"  // Original dimensions
    
    var approximatePixels: Int {
        switch self {
        case .thumbnail: 140
        case .standard: 760
        case .high: 1600
        case .ultra: 2560
        case .original: 4000 // Estimate for cache calculations
        }
    }
}

