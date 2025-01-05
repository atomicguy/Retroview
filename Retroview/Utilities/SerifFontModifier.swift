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

struct SerifNavigationTitleModifier: ViewModifier {
    let title: String
    let displayMode: NavigationTitleDisplayMode
    
    func body(content: Content) -> some View {
        content.toolbar {
            ToolbarItem(placement: .principal) {
                Text(title)
                    .font(.system(.title, design: .serif))
            }
        }
        .navigationTitle(title) // Keep original title for system purposes
    }
}

extension View {
    func serifNavigationTitle(_ title: String, displayMode: NavigationTitleDisplayMode = .automatic) -> some View {
        modifier(SerifNavigationTitleModifier(title: title, displayMode: displayMode))
    }
}
