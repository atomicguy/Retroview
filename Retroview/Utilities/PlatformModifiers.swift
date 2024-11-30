//
//  PlatformModifiers.swift
//  Retroview
//
//  Created by Assistant on 11/29/24.
//

import SwiftUI

// MARK: - Navigation Title Modifier

struct PlatformNavigationTitleModifier: ViewModifier {
    let title: String
    let displayMode: NavigationTitleDisplayMode

    init(title: String, displayMode: NavigationTitleDisplayMode = .automatic) {
        self.title = title
        self.displayMode = displayMode
    }

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

struct PlatformToolbarContent: ToolbarContent {
    let leadingContent: AnyView
    let trailingContent: AnyView

    var body: some ToolbarContent {
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

struct PlatformToolbarModifier: ViewModifier {
    let leadingContent: AnyView
    let trailingContent: AnyView

    func body(content: Content) -> some View {
        content.toolbar {
            PlatformToolbarContent(
                leadingContent: leadingContent,
                trailingContent: trailingContent
            )
        }
    }
}

// MARK: - Background Modifier

struct PlatformBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        #if os(iOS)
            content.background(Color(uiColor: .systemBackground))
        #elseif os(macOS)
            content.background(Color(nsColor: .windowBackgroundColor))
        #else
            content
        #endif
    }
}

// MARK: - Supporting Types

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

    func platformBackground() -> some View {
        modifier(PlatformBackgroundModifier())
    }
}

// MARK: - Platform-Specific Button Styles

extension View {
    func platformDismissButton(action: @escaping () -> Void) -> some View {
        #if os(macOS)
            Button("Cancel", action: action)
        #else
            Button("Done", action: action)
        #endif
    }
}

// MARK: - Toolbar Item Helper

extension View {
    func toolbarButton(
        title: String,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button {
            action()
        } label: {
            Label(title, systemImage: systemImage)
        }
    }
}

// MARK: - Preview Provider

#if DEBUG
    struct PlatformModifiersPreview: View {
        var body: some View {
            NavigationStack {
                List {
                    Text("Sample Content")
                }
                .platformNavigationTitle("Preview Title", displayMode: .inline)
                .platformToolbar {
                    toolbarButton(
                        title: "Back",
                        systemImage: "chevron.left"
                    ) {}
                } trailing: {
                    toolbarButton(
                        title: "Add",
                        systemImage: "plus"
                    ) {}
                }
                .platformBackground()
            }
        }
    }

    #Preview("Platform Modifiers") {
        PlatformModifiersPreview()
    }
#endif
