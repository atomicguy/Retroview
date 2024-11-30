//
//  InteractionState.swift
//  Retroview
//
//  Created by Adam Schuster on 11/29/24.
//

import SwiftUI

@MainActor
class InteractionState: ObservableObject {
    @Published var isActive = false
    
    func activate() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isActive = true
        }
    }
    
    func deactivate() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isActive = false
        }
    }
}

struct CardInteractionModifier: ViewModifier {
    @StateObject private var interactionState = InteractionState()
    let content: (Bool) -> AnyView
    
    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { _ in
                    self.content(interactionState.isActive)
                        .allowsHitTesting(true)
                }
            }
            // Handle hover for platforms with pointer devices
            .onHover { hovering in
                if hovering {
                    interactionState.activate()
                } else {
                    interactionState.deactivate()
                }
            }
            // Handle long press for touch devices
            .onLongPressGesture(minimumDuration: 0.3) {
                interactionState.activate()
            }
            // Handle tap outside to dismiss on touch devices
            .onTapGesture {
                interactionState.deactivate()
            }
    }
}

extension View {
    func withCardInteraction<Content: View>(
        @ViewBuilder content: @escaping (Bool) -> Content
    ) -> some View {
        modifier(
            CardInteractionModifier(content: { isActive in
                AnyView(content(isActive))
            })
        )
    }
}
