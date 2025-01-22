//
//  DebossedModifier.swift
//  Retroview
//
//  Created by Adam Schuster on 1/21/25.
//

import SwiftUI

struct DebossedText: ViewModifier {
    let color: Color
    
    func body(content: Content) -> some View {
        content
            .overlay {
                ZStack {
                    // Dark shadow on top
                    content
                        .foregroundStyle(Color.black.opacity(0.3))
                        .offset(y: 1)
                    
                    // Light shadow on bottom
                    content
                        .foregroundStyle(Color.white.opacity(0.7))
                        .offset(y: -1)
                    
                    // Original text
                    content
                        .foregroundStyle(color)
                }
            }
    }
}

extension View {
    func debossed(color: Color = .gray) -> some View {
        modifier(DebossedText(color: color))
    }
}
