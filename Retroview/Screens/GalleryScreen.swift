//
//  GalleryScreen.swift
//  Retroview
//
//  Created by Adam Schuster on 11/26/24.
//

import SwiftData
import SwiftUI

struct GalleryScreen: View {
    @State private var selectedDestination: NavigationDestination = .library

    var body: some View {
        NavigationSplitView {
            // Sidebar
            List(selection: $selectedDestination) {
                NavigationLink(value: NavigationDestination.library) {
                    Label(
                        NavigationDestination.library.label,
                        systemImage: NavigationDestination.library.systemImage)
                }
            }
            .navigationTitle("Retroview")
            .frame(idealWidth: 100) // Width of "Library" + icon + padding
        } detail: {
            // Main content area
            switch selectedDestination {
            case .library:
                LibraryView()
            }
        }
        .navigationSplitViewStyle(.automatic)
    }
}

// MARK: - Preview Provider

#Preview("Gallery") {
    GalleryScreen()
        .withPreviewContainer()
        .frame(width: 1200, height: 800)
}
