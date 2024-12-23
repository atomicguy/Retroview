//
//  SerifFontModifier.swift
//  Retroview
//
//  Created by Adam Schuster on 12/22/24.
//

import SwiftUI

struct SerifFontModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(.body, design: .serif))
    }
}

extension View {
    func serifFont() -> some View {
        modifier(SerifFontModifier())
    }
}
