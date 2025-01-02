//
//  PlatformModifiers.swift
//  Retroview
//
//  Created by Assistant on 11/29/24.
//

import SwiftUI

// MARK: - Platform Environment
enum PlatformEnvironment {
    // Platform Detection
    static var isVisionOS: Bool {
        #if os(visionOS)
            return true
        #else
            return false
        #endif
    }

    static var isMacOS: Bool {
        #if os(macOS)
            return true
        #else
            return false
        #endif
    }

    static var isiPadOS: Bool {
        #if os(iOS)
            return true
        #else
            return false
        #endif
    }

    // UI Metrics
    struct Metrics {
        // Grid Layout
        static var gridMinWidth: CGFloat {
            isMacOS ? 300 : 250
        }

        static var gridMaxWidth: CGFloat {
            isMacOS ? 400 : 350
        }

        static var gridSpacing: CGFloat {
            isMacOS ? 16 : 12
        }

        // Flow Layout
        static var flowLayoutSpacing: CGFloat {
            isMacOS ? 8 : 6
        }

        // General Spacing
        static var defaultPadding: CGFloat {
            isMacOS ? 16 : 12
        }

        static var compactPadding: CGFloat {
            isMacOS ? 12 : 8
        }
    }
}

// MARK: - Navigation Title Display Mode
enum NavigationTitleDisplayMode {
    case automatic
    case inline
    case large

    #if !os(macOS)
        var navigationBarDisplayMode: NavigationBarItem.TitleDisplayMode {
            switch self {
            case .automatic: return .automatic
            case .inline: return .inline
            case .large: return .large
            }
        }
    #endif
}

// MARK: - View Modifiers
struct PlatformNavigationTitleModifier: ViewModifier {
    let title: String
    let displayMode: NavigationTitleDisplayMode

    func body(content: Content) -> some View {
        #if os(macOS)
            content.navigationTitle(title)
        #else
            content
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(
                    displayMode.navigationBarDisplayMode)
        #endif
    }
}

struct PlatformToolbarModifier: ViewModifier {
    let leadingContent: AnyView
    let trailingContent: AnyView

    func body(content: Content) -> some View {
        content.toolbar {
            #if os(visionOS)
                ToolbarItem(placement: .topBarLeading) {
                    leadingContent
                }
                ToolbarItem(placement: .topBarTrailing) {
                    trailingContent
                }
            #elseif os(iOS)
                ToolbarItem(placement: .navigationBarLeading) {
                    leadingContent
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    trailingContent
                }
            #else
                ToolbarItem(placement: .cancellationAction) {
                    leadingContent
                }
                ToolbarItem(placement: .confirmationAction) {
                    trailingContent
                }
            #endif
        }
    }
}

// MARK: - View Extensions
extension View {
    func platformNavigationTitle(
        _ title: String,
        displayMode: NavigationTitleDisplayMode = .automatic
    ) -> some View {
        modifier(
            PlatformNavigationTitleModifier(
                title: title, displayMode: displayMode))
    }

    func platformToolbar(
        @ViewBuilder leading: () -> some View = { EmptyView() },
        @ViewBuilder trailing: () -> some View = { EmptyView() }
    ) -> some View {
        modifier(
            PlatformToolbarModifier(
                leadingContent: AnyView(leading()),
                trailingContent: AnyView(trailing())
            ))
    }
}

// MARK: - Vision OS Interaction Modifiers
extension View {
    func platformInteraction() -> some View {
        #if os(visionOS)
            self.contentShape(RoundedRectangle(cornerRadius: 12))
                .hoverEffect(.highlight)
        #elseif os(macOS)
            self
        #else
            self
        #endif
    }

    func platformSelectionEffect(isSelected: Bool = false) -> some View {
        #if os(visionOS)
            return
                self
                .overlay {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.white.opacity(0.8), lineWidth: 2)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.white.opacity(0.2))
                            )
                    }
                }
        #else
            return self
        #endif
    }

    func platformTapAction(singleTapAction: @escaping () -> Void) -> some View {
        #if os(visionOS)
            self.onTapGesture {
                singleTapAction()
            }
        #else
            self
        #endif
    }
}

extension View {
    func platformHoverState(action: @escaping (Bool) -> Void) -> some View {
        #if os(visionOS)
            self.hoverEffect(.highlight)
        #elseif os(macOS)
            self.onHover { hovering in
                action(hovering)
            }
        #else
            self
        #endif
    }

    func platformTapAction(
        singleTapAction: @escaping () -> Void,
        doubleTapAction: @escaping () -> Void
    ) -> some View {
        self.modifier(
            PlatformTapModifier(
                singleTapAction: singleTapAction,
                doubleTapAction: doubleTapAction
            ))
    }

    func platformHoverBinding() -> Binding<Bool> {
        @State var isHovering = false
        return Binding(
            get: { isHovering },
            set: { isHovering = $0 }
        )
    }
}

private struct PlatformTapModifier: ViewModifier {
    let singleTapAction: () -> Void
    let doubleTapAction: () -> Void
    
    func body(content: Content) -> some View {
        #if os(visionOS)
            content
                .onTapGesture(perform: doubleTapAction)
        #elseif os(macOS)
            content
                .simultaneousGesture(
                    TapGesture(count: 1)
                        .onEnded(singleTapAction)
                )
                .simultaneousGesture(
                    TapGesture(count: 2)
                        .onEnded(doubleTapAction)
                )
        #else
            // On iPadOS, single tap navigates directly
            content
                .onTapGesture(perform: doubleTapAction)
        #endif
    }
}
