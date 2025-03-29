//
//  ColorUtility.swift
//  Retroview
//
//  Created by Adam Schuster on 11/27/24.
//

import SwiftUI

#if os(macOS)
    import AppKit
#else
    import UIKit
#endif

extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(
            in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r: UInt64
        let g: UInt64
        let b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (r, g, b) = (
                (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17
            )
        case 6: // RGB (24-bit)
            (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        self.init(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255
        )
    }

    func toHex() -> String? {
        #if os(macOS)
            let color = NSColor(self)
            guard let components = color.cgColor.components,
                  components.count >= 3
            else {
                return nil
            }
        #else
            let color = UIColor(self)
            guard let components = color.cgColor.components,
                  components.count >= 3
            else {
                return nil
            }
        #endif

        let r = Float(components[0])
        let g = Float(components[1])
        let b = Float(components[2])
        return String(
            format: "#%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255)
        )
    }
}
