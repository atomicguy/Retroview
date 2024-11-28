//
//  GalleryScreen.swift
//  Retroview
//
//  Created by Adam Schuster on 11/26/24.
//

import SwiftData
import SwiftUI

struct GalleryScreen: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedDestination: NavigationDestination = .library
    @State private var showingImport = false

    var body: some View {
        NavigationSplitView {
            // Sidebar
            List(selection: $selectedDestination) {
                NavigationLink(value: NavigationDestination.library) {
                    Label(
                        NavigationDestination.library.label,
                        systemImage: NavigationDestination.library.systemImage
                    )
                }
            }
            .navigationTitle("Retroview")
            .frame(idealWidth: 100) // Width of "Library" + icon + padding
        } detail: {
            // Main content area
            switch selectedDestination {
            case .library:
                LibraryView()
                    .toolbar {
                        ToolbarItem {
                            Button {
                                showingImport = true
                            } label: {
                                Label(
                                    "Import Cards",
                                    systemImage: "square.and.arrow.down"
                                )
                            }
                        }
                    }
            }
        }
        .navigationSplitViewStyle(.automatic)
        .sheet(isPresented: $showingImport) {
            ImportView(modelContext: modelContext)
        }
    }
}

#Preview("Gallery") {
    GalleryScreen()
        .withPreviewContainer()
        .frame(width: 1200, height: 800)
}
