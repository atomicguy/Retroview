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
                .onChange(of: showSecondaryMenu) {
                    if !showSecondaryMenu {
                        withAnimation(.spring(response: 0.3)) {
                            longPressScale = 1.0
                        }
                    }
                }
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
    @State private var navigationInProgress = false

    func body(content: Content) -> some View {
        content
            #if os(visionOS)
                .onTapGesture {
                    guard !navigationInProgress else { return }
                    navigationInProgress = true
                    onDoubleTap?()
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
                .onTapGesture {
                    guard !navigationInProgress else { return }
                    navigationInProgress = true
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
    let subtitle: String?
    let displayMode: NavigationTitleDisplayMode

    func body(content: Content) -> some View {
        content
            #if os(macOS)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        VStack {
                            Text(title)
                            .font(.system(.title, design: .serif))
                            if let subtitle = subtitle {
                                Text(subtitle)
                                .font(.system(.subheadline))
                                .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            #else
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(
                    displayMode.navigationBarDisplayMode
                )
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        VStack {
                            Text(title)
                            .font(.system(.title, design: .serif))
                            if let subtitle = subtitle {
                                Text(subtitle)
                                .font(.system(.subheadline))
                                .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
            #endif
    }
}

// MARK: - Toolbar Modifier
struct PlatformToolbarModifier: ViewModifier {
    let leadingContent: [AnyView]
    let trailingContent: [AnyView]

    func body(content: Content) -> some View {
        content.toolbar {
            #if os(visionOS)
                ToolbarItemGroup(placement: .topBarLeading) {
                    ForEach(Array(leadingContent.enumerated()), id: \.offset) {
                        _, content in
                        content
                    }
                }
                ToolbarItemGroup(placement: .topBarTrailing) {
                    ForEach(Array(trailingContent.enumerated()), id: \.offset) {
                        _, content in
                        content
                    }
                }
            #elseif os(iOS)
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    ForEach(Array(leadingContent.enumerated()), id: \.offset) {
                        _, content in
                        content
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    ForEach(Array(trailingContent.enumerated()), id: \.offset) {
                        _, content in
                        content
                    }
                }
            #else
                ToolbarItemGroup(placement: .cancellationAction) {
                    ForEach(Array(leadingContent.enumerated()), id: \.offset) {
                        _, content in
                        content
                    }
                }
                ToolbarItemGroup(placement: .confirmationAction) {
                    ForEach(Array(trailingContent.enumerated()), id: \.offset) {
                        _, content in
                        content
                    }
                }
            #endif
        }
    }
}

// MARK - Overlay Buttons
struct OverlayButtonStyle: ViewModifier {
    let opacity: Double

    init(opacity: Double = 1.0) {
        self.opacity = opacity
    }

    func body(content: Content) -> some View {
        content
            .font(.title2)
            .foregroundStyle(.white)
            .shadow(radius: 2)
            .opacity(opacity)
            .frame(width: 44, height: 44)
            .contentShape(Rectangle())
    }
}

// MARK: - View Extensions
extension View {
    func platformInteraction(
        _ config: InteractionConfig,
        subtitle: String? = nil
    ) -> some View {
        modifier(PlatformInteractionModifier(config: config))
    }

    func platformNavigationTitle(
        _ title: String,
        subtitle: String? = nil,
        displayMode: NavigationTitleDisplayMode = .automatic
    ) -> some View {
        modifier(
            PlatformNavigationTitleModifier(
                title: title,
                subtitle: subtitle,
                displayMode: displayMode
            )
        )
    }

    func platformToolbar(
        @ViewBuilder leading: () -> some View = { EmptyView() },
        @ViewBuilder trailing: () -> some View = { EmptyView() }
    ) -> some View {
        modifier(
            PlatformToolbarModifier(
                leadingContent: [AnyView(leading())],
                trailingContent: [AnyView(trailing())]
            )
        )
    }

    func overlayButtonStyle(opacity: Double = 1.0) -> some View {
        modifier(OverlayButtonStyle(opacity: opacity))
    }
}

struct PlatformHoverEffect: ViewModifier {
    let cornerRadius: CGFloat
    @State private var isHovering = false

    func body(content: Content) -> some View {
        content
            #if os(visionOS)
                .hoverEffect(.highlight)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            #elseif os(macOS)
                .onHover { hovering in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isHovering = hovering
                    }
                }
                .opacity(isHovering ? 0.8 : 1.0)
            #endif
    }
}

extension View {
    func platformHover(cornerRadius: CGFloat = 12) -> some View {
        modifier(PlatformHoverEffect(cornerRadius: cornerRadius))
    }
}

// Test Views for Previews
private struct PreviewCard: View {
    let title: String
    let isSelected: Bool
    let showHover: Bool
    let onTap: (() -> Void)?
    let onDoubleTap: (() -> Void)?

    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.gray.opacity(0.1))
            .frame(width: 200, height: 150)
            .overlay {
                Text(title)
                    .foregroundStyle(.secondary)
            }
            .platformInteraction(
                InteractionConfig(
                    onTap: onTap,
                    onDoubleTap: onDoubleTap,
                    onSecondaryAction: {
                        AnyView(
                            Menu {
                                Button("Action 1") {}
                                Button("Action 2") {}
                            } label: {
                                Text("Context Menu")
                            }
                        )
                    },
                    isSelected: isSelected,
                    showHoverEffects: showHover
                )
            )
    }
}

// Platform Interaction Preview
#Preview("Platform Interaction States") {
    VStack(spacing: 20) {
        HStack(spacing: 20) {
            PreviewCard(
                title: "Normal",
                isSelected: false,
                showHover: true,
                onTap: {},
                onDoubleTap: {}
            )

            PreviewCard(
                title: "Selected",
                isSelected: true,
                showHover: true,
                onTap: {},
                onDoubleTap: {}
            )
        }

        HStack(spacing: 20) {
            PreviewCard(
                title: "No Hover Effects",
                isSelected: false,
                showHover: false,
                onTap: {},
                onDoubleTap: {}
            )

            PreviewCard(
                title: "Right Click/Long Press for Menu",
                isSelected: false,
                showHover: true,
                onTap: {},
                onDoubleTap: {}
            )
        }
    }
    .padding()
}

// Navigation Title Preview
#Preview("Navigation Title Styles") {
    NavigationStack {
        List {
            Text("Content")
        }
        .platformNavigationTitle("Automatic Title")

        List {
            Text("Content")
        }
        .platformNavigationTitle("Inline Title", displayMode: .inline)

        List {
            Text("Content")
        }
        .platformNavigationTitle("Large Title", displayMode: .large)
    }
}

// Toolbar Preview
#Preview("Platform Toolbar") {
    NavigationStack {
        Text("Content")
            .platformToolbar {
                Button("Cancel") {
                    print("Cancel tapped")
                }
            } trailing: {
                Button("Done") {
                    print("Done tapped")
                }
            }
            .platformNavigationTitle("Toolbar Example")
    }
}

// Overlay Button Preview
#Preview("Overlay Button Styles") {
    HStack(spacing: 20) {
        // Normal overlay button
        Button {
        } label: {
            Image(systemName: "heart")
                .overlayButtonStyle()
        }
        .buttonStyle(.plain)

        // Dimmed overlay button
        Button {
        } label: {
            Image(systemName: "square.and.arrow.up")
                .overlayButtonStyle(opacity: 0.5)
        }
        .buttonStyle(.plain)
    }
    .padding(40)
    .background {
        Color.gray.opacity(0.3)
    }
}
