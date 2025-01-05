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

// MARK: - Interaction Configuration
struct InteractionConfig {
    var onTap: (() -> Void)?
    var onDoubleTap: (() -> Void)?
    var onSecondaryAction: (() -> AnyView)?
    var isSelected: Bool
    var showHoverEffects: Bool

    init(
        onTap: (() -> Void)? = nil,
        onDoubleTap: (() -> Void)? = nil,
        onSecondaryAction: (() -> AnyView)? = nil,
        isSelected: Bool = false,
        showHoverEffects: Bool = true
    ) {
        self.onTap = onTap
        self.onDoubleTap = onDoubleTap
        self.onSecondaryAction = onSecondaryAction
        self.isSelected = isSelected
        self.showHoverEffects = showHoverEffects
    }
}

// MARK: - Platform Interaction Modifier
struct PlatformInteractionModifier: ViewModifier {
    let config: InteractionConfig
    @State private var isHovering = false
    @State private var showSecondaryMenu = false
    @State private var scale = 1.0
    @State private var longPressScale = 1.0

    func body(content: Content) -> some View {
        content
            .contentShape(RoundedRectangle(cornerRadius: 12))
            .modifier(
                HoverEffectModifier(
                    isHovering: $isHovering,
                    showEffects: config.showHoverEffects
                )
            )
            .modifier(SelectionEffectModifier(isSelected: config.isSelected))
            .scaleEffect(scale * longPressScale)
            .animation(
                .snappy(duration: 0.3), value: scale
            )
            .animation(
                .bouncy(duration: 0.3),
                value: longPressScale
            )
            #if os(visionOS)
                // On visionOS, tap scales down briefly and navigates
                .gesture(
                    TapGesture()
                        .onEnded {
                            withAnimation {
                                scale = 0.95
                            }
                            // Delay to show animation before navigation
                            DispatchQueue.main.asyncAfter(
                                deadline: .now() + 0.1
                            ) {
                                withAnimation {
                                    scale = 1.0
                                }
                                config.onDoubleTap?()  // Navigate on tap
                            }
                        }
                )
                // Long press for menu
                .gesture(
                    LongPressGesture(minimumDuration: 0.5)
                        .onEnded { _ in
                            // When long press completes, scale up and show menu
                            withAnimation(.bouncy(duration: 0.3)) {
                                longPressScale = 1.1
                                showSecondaryMenu = true
                            }
                        }
                )
                .onChange(of: showSecondaryMenu) {
                    if !showSecondaryMenu {
                        withAnimation {
                            longPressScale = 1.0
                        }
                    }
                }
            #elseif os(iOS)
                // On iPadOS, tap navigates and shows brief scale
                .simultaneousGesture(
                    TapGesture()
                        .onEnded {
                            withAnimation(.spring(response: 0.2)) {
                                scale = 0.95
                            }
                            DispatchQueue.main.asyncAfter(
                                deadline: .now() + 0.1
                            ) {
                                withAnimation(.spring(response: 0.2)) {
                                    scale = 1.0
                                }
                                config.onDoubleTap?()  // Navigate on tap
                            }
                        }
                )
                // Long press for menu
                .gesture(
                    LongPressGesture(minimumDuration: 0.5)
                        .onEnded { _ in
                            withAnimation(.spring(response: 0.3)) {
                                longPressScale = 1.1
                                showSecondaryMenu = true
                            }
                        }
                )
            #else
                // macOS keeps existing behavior
                .modifier(
                    TapHandlingModifier(
                        onTap: config.onTap,
                        onDoubleTap: config.onDoubleTap
                    ))
            #endif
            .modifier(
                SecondaryActionModifier(
                    isPresented: $showSecondaryMenu,
                    content: config.onSecondaryAction
                ))
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

// MARK: - Platform-Specific Modifiers
private struct HoverEffectModifier: ViewModifier {
    @Binding var isHovering: Bool
    let showEffects: Bool

    func body(content: Content) -> some View {
        content
            #if os(visionOS)
                .hoverEffect()
            #elseif os(macOS)
                .onHover { hovering in
                    guard showEffects else { return }
                    isHovering = hovering
                }
                .opacity(isHovering && showEffects ? 0.8 : 1.0)
            #endif
    }
}

private struct SelectionEffectModifier: ViewModifier {
    let isSelected: Bool

    func body(content: Content) -> some View {
        content
            .overlay {
                if isSelected {
                    #if os(visionOS)
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.white.opacity(0.8), lineWidth: 2)
                    #else
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.accentColor, lineWidth: 2)
                    #endif
                }
            }
    }
}

private struct TapHandlingModifier: ViewModifier {
    let onTap: (() -> Void)?
    let onDoubleTap: (() -> Void)?

    func body(content: Content) -> some View {
        content
            #if os(visionOS)
                .onTapGesture {
                    onDoubleTap?()  // visionOS uses single tap for navigation
                }
            #elseif os(macOS)
                .simultaneousGesture(
                    TapGesture(count: 1)
                        .onEnded {
                            onTap?()
                        }
                )
                .simultaneousGesture(
                    TapGesture(count: 2)
                        .onEnded {
                            onDoubleTap?()
                        }
                )
            #else
                // iPadOS uses single tap for navigation
                .onTapGesture {
                    onDoubleTap?()
                }
            #endif
    }
}

private struct SecondaryActionModifier: ViewModifier {
    @Binding var isPresented: Bool
    let content: (() -> AnyView)?

    func body(content: Content) -> some View {
        content
            #if os(macOS)
                .contextMenu {
                    if let menuContent = self.content {
                        menuContent()
                    }
                }
            #else
                .popover(
                    isPresented: $isPresented,
                    attachmentAnchor: .rect(.bounds)
                ) {
                    if let menuContent = self.content {
                        menuContent()
                        .presentationCompactAdaptation(.none)
                        .presentationBackground(.ultraThinMaterial)
                    }
                }
            #endif
    }
}

// Add a preference key to track popover position
private struct PopoverPositionPreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

// MARK: - Navigation Title Modifier
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

// MARK: - Toolbar Modifier
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
    func platformInteraction(_ config: InteractionConfig) -> some View {
        modifier(PlatformInteractionModifier(config: config))
    }

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
            )
        )
    }
}
