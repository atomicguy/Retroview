//
//  ColorUtility.swift
//  Retroview
//
//  Created by Adam Schuster on 12/9/24.
//

import SwiftUI

extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: .alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: Double
        switch hex.count {
        case 3:
            (r, g, b) = (
                Double((int >> 8) & 0xFF) / 255,
                Double((int >> 4) & 0xFF) / 255,
                Double(int & 0xFF) / 255
            )
        case 6:
            (r, g, b) = (
                Double((int >> 16) & 0xFF) / 255,
                Double((int >> 8) & 0xFF) / 255,
                Double(int & 0xFF) / 255
            )
        default:
            return nil
        }
        self.init(red: r, green: g, blue: b)
    }
    
    func toHex() -> String? {
        guard let components = cgColor?.components,
              components.count >= 3 else { return nil }
        
        return String(
            format: "#%02X%02X%02X",
            Int(components[0] * 255),
            Int(components[1] * 255),
            Int(components[2] * 255)
        )
    }
}
