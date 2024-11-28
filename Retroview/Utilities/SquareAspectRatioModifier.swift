//
//  SquareAspectRatioModifier.swift
//  Retroview
//
//  Created by Adam Schuster on 11/27/24.
//

import SwiftUI

/// A view modifier that forces a view to maintain a square (1:1) aspect ratio
/// while respecting layout constraints and available space.
struct SquareAspectRatioModifier: ViewModifier {
    func body(content: Content) -> some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)

            content
                .frame(width: size, height: size)
                .position(
                    x: geometry.frame(in: .local).midX,
                    y: geometry.frame(in: .local).midY
                )
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

extension View {
    /// Forces the view to maintain a square (1:1) aspect ratio while respecting
    /// layout constraints and available space.
    func squareAspectRatio() -> some View {
        modifier(SquareAspectRatioModifier())
    }
}

#Preview {
    VStack(spacing: 20) {
        // Square in different container sizes
        Color.blue
            .squareAspectRatio()
            .frame(width: 200, height: 100)

        Color.red
            .squareAspectRatio()
            .frame(width: 100, height: 200)

        Color.green
            .squareAspectRatio()
            .frame(width: 150, height: 150)
    }
    .padding()
}
