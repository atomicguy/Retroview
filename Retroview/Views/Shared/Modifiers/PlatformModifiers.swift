//
//  PlatformModifiers.swift
//  Retroview
//
//  Created by Adam Schuster on 12/9/24.
//

import SwiftUI

struct PlatformNavigationModifier: ViewModifier {
    let title: String
    
    func body(content: Content) -> some View {
        #if os(macOS)
        content
            .navigationTitle(title)
        #else
        content
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}
