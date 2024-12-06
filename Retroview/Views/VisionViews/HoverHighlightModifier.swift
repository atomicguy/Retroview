//
//  GlanceHighlightModifier.swift
//  Retroview
//
//  Created by Adam Schuster on 12/4/24.
//

import SwiftUI

#if os(visionOS)
struct HoverHighlightModifier: ViewModifier {
    @State private var isHovering = false
    
    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.clear)
                    .background(.ultraThinMaterial.tertiary)
                    .opacity(isHovering ? 0.6 : 0)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .animation(.smooth, value: isHovering)
            }
            .onHover { hovering in
                isHovering = hovering
            }
    }
}

extension View {
    func hoverHighlight() -> some View {
        modifier(HoverHighlightModifier())
    }
}
#endif
