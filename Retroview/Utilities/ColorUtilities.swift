//
//  ColorUtilities.swift
//  Retroview
//
//  Created by Adam Schuster on 12/8/24.
//

import SwiftUI

extension Color {
    func toHex() -> String? {
        // Convert Color to CGColor
        guard let components = cgColor?.components else { return nil }
        
        // Extract RGB components
        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        
        // Convert to hex string
        return String(format: "#%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255))
    }
    
    init?(hex: String) {
        // Remove '#' if present
        var cleanHex = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if cleanHex.hasPrefix("#") {
            cleanHex.remove(at: cleanHex.startIndex)
        }
        
        // Convert hex to RGB
        var rgb: UInt64 = 0
        guard Scanner(string: cleanHex).scanHexInt64(&rgb) else {
            return nil
        }
        
        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}

#if canImport(UIKit)
extension Color {
    var cgColor: CGColor? {
        UIColor(self).cgColor
    }
}
#elseif canImport(AppKit)
extension Color {
    var cgColor: CGColor? {
        NSColor(self).cgColor
    }
}
#endif
