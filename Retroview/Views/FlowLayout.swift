//
//  FlowLayout.swift
//  Retroview
//
//  Created by Adam Schuster on 12/17/24.
//

import SwiftUI

// The Layout implementation
struct FlowLayout: Layout {
    var spacing: CGFloat
    
    init(spacing: CGFloat? = nil) {
        self.spacing = spacing ?? PlatformEnvironment.Metrics.flowLayoutSpacing
    }
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        var width: CGFloat = 0
        var height: CGFloat = 0
        var lineWidth: CGFloat = 0
        var lineHeight: CGFloat = 0
        
        for size in sizes {
            if lineWidth + size.width > (proposal.width ?? .infinity) && lineWidth > 0 {
                width = max(width, lineWidth)
                height += lineHeight + spacing
                lineWidth = size.width + spacing
                lineHeight = size.height
            } else {
                lineWidth += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }
        }
        
        return CGSize(
            width: max(width, lineWidth),
            height: height + lineHeight
        )
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        var x = bounds.minX
        var y = bounds.minY
        var lineHeight: CGFloat = 0
        
        for (index, subview) in subviews.enumerated() {
            let size = sizes[index]
            
            if x + size.width > bounds.maxX && x > bounds.minX {
                x = bounds.minX
                y += lineHeight + spacing
                lineHeight = 0
            }
            
            subview.place(
                at: CGPoint(x: x, y: y),
                proposal: .unspecified
            )
            
            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}

// A view that uses FlowLayout
struct FlowLayoutView: View {
    let spacing: CGFloat?
    let content: () -> any View
    
    init(spacing: CGFloat? = nil, @ViewBuilder content: @escaping () -> any View) {
        self.spacing = spacing
        self.content = content
    }
    
    var body: some View {
        FlowLayout(spacing: spacing) {
            AnyView(content())
        }
    }
}

// View modifier to make it easy to use FlowLayout
struct FlowLayoutModifier: ViewModifier {
    let spacing: CGFloat?
    
    func body(content: Content) -> some View {
        FlowLayoutView(spacing: spacing) {
            content
        }
    }
}

// Extension to make it easy to use as a view modifier
extension View {
    func flowLayout(spacing: CGFloat? = nil) -> some View {
        modifier(FlowLayoutModifier(spacing: spacing))
    }
}
