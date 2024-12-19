//
//  SerifModifier.swift
//  Retroview
//
//  Created by Adam Schuster on 12/18/24.
//

import SwiftUI

struct SerifyModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .environment(\.font, .system(.body, design: .serif))
    }
}

extension View {
    func serifyText() -> some View {
        modifier(SerifyModifier())
    }
}

// For consistent font scaling across different text styles
struct SerifFonts {
    static let largeTitle = Font.system(.largeTitle, design: .serif)
    static let title = Font.system(.title, design: .serif)
    static let title2 = Font.system(.title2, design: .serif)
    static let title3 = Font.system(.title3, design: .serif)
    static let headline = Font.system(.headline, design: .serif)
    static let subheadline = Font.system(.subheadline, design: .serif)
    static let body = Font.system(.body, design: .serif)
    static let callout = Font.system(.callout, design: .serif)
    static let caption = Font.system(.caption, design: .serif)
    static let caption2 = Font.system(.caption2, design: .serif)
    static let footnote = Font.system(.footnote, design: .serif)
}
