//
//  GlanceHighlightModifier.swift
//  Retroview
//
//  Created by Adam Schuster on 12/4/24.
//

import SwiftUI
import UIKit

#if os(visionOS)
struct GlanceHighlightModifier: ViewModifier {
    @Environment(\.glanceDirection.horizontal) private var horizontalDirection: UIGestureRecognizer.GlanceDirection.Horizontal?
    @Environment(\.glanceDirection.vertical) private var verticalDirection: UIGestureRecognizer.GlanceDirection.Vertical?
    
    var isGlancing: Bool {
        horizontalDirection != nil || verticalDirection != nil
    }
    
    func body(content: Content) -> some View {
        content
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(.clear)
                    .background(.ultraThinMaterial.tertiary)
                    .opacity(isGlancing ? 0.6 : 0)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .animation(.smooth, value: isGlancing)
            }
    }
}

extension View {
    func glanceHighlight() -> some View {
        modifier(GlanceHighlightModifier())
    }
}
#endif
