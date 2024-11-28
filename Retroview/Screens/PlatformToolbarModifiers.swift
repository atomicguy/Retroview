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
                        debugButtons
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
                        debugButtons
                    }
                #endif
            #endif
        }
    }

    #if DEBUG
        private var debugButtons: some View {
            Menu("Debug") {
                Button(role: .destructive) {
                    RetroviewApp.clearAllData()
                } label: {
                    Label("Clear All Data", systemImage: "trash")
                }
            }
        }
    #endif
}

extension View {
    func platformToolbar(importAction: @escaping () -> Void) -> some View {
        modifier(PlatformToolbarModifiers(importAction: importAction))
    }
}
