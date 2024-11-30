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
            NavigationSidebar(selectedDestination: $selectedDestination)
        } detail: {
            navigationDestinationView
                .platformToolbar {
                    showingImport = true
                }
        }
        .navigationSplitViewStyle(.automatic)
        .sheet(isPresented: $showingImport) {
            ImportView(modelContext: modelContext)
        }
        #if os(iOS)
        .navigationViewStyle(.stack)
        .ignoresSafeArea(.keyboard)
        #endif
        // Use GeometryReader to fill available space
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // Ensure content fills the safe area
        .ignoresSafeArea(.container, edges: [.leading, .trailing])
        // Add platform-specific styling
        .modifier(PlatformSpecificModifier())
    }

    @ViewBuilder
    private var navigationDestinationView: some View {
        switch selectedDestination {
        case .library:
            LibraryView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .subjects:
            SubjectsView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case let .collection(id, _):
            if let collection = fetchCollection(id: id) {
                CollectionView(collection: collection)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ContentUnavailableView(
                    "Collection Not Found",
                    systemImage: "folder.badge.questionmark",
                    description: Text("The selected collection could not be found")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    private func fetchCollection(id: UUID) -> CollectionSchemaV1.Collection? {
        let descriptor = FetchDescriptor<CollectionSchemaV1.Collection>(
            predicate: #Predicate<CollectionSchemaV1.Collection> { collection in
                collection.id == id
            }
        )
        return try? modelContext.fetch(descriptor).first
    }
}

// Platform-specific styling
private struct PlatformSpecificModifier: ViewModifier {
    func body(content: Content) -> some View {
        #if os(iOS)
        content
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(uiColor: .systemBackground))
        #elseif os(macOS)
        content
            .background(Color(nsColor: .windowBackgroundColor))
        #else
        content
        #endif
    }
}

#Preview("Gallery") {
    GalleryScreen()
        .withPreviewContainer()
        .frame(width: 1200, height: 800)
}

#Preview("Gallery - iPad") {
    GalleryScreen()
        .withPreviewContainer()
}
