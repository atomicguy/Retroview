//
//  PlatformToolbarModifiers.swift
//  Retroview
//
//  Created by Adam Schuster on 11/27/24.
//

import SwiftUI

struct PlatformToolbarModifiers: ViewModifier {
    let importAction: () -> Void

    func body(content: Content) -> some View {
        content.toolbar {
            #if os(visionOS)
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: importAction) {
                        Label(
                            "Import Cards", systemImage: "square.and.arrow.down"
                        )
                    }
                }
                #if DEBUG
                    ToolbarItem(placement: .topBarTrailing) {
                        DebugMenu()
                    }
                #endif
            #else
                ToolbarItem(placement: .automatic) {
                    Button(action: importAction) {
                        Label(
                            "Import Cards", systemImage: "square.and.arrow.down"
                        )
                    }
                }
                #if DEBUG
                    ToolbarItem(placement: .automatic) {
                        DebugMenu()
                    }
                #endif
            #endif
        }
    }
}

extension View {
    func platformToolbar(importAction: @escaping () -> Void) -> some View {
        modifier(PlatformToolbarModifiers(importAction: importAction))
    }
}
