//
//  GalleryScreen.swift
//  Retroview
//
//  Created by Adam Schuster on 11/26/24.
//

import SwiftData
import SwiftUI

private struct NavigationSidebar: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var selectedDestination: NavigationDestination
    @Query(sort: \CollectionSchemaV1.Collection.name) private var collections:
        [CollectionSchemaV1.Collection]

    var body: some View {
        List(selection: $selectedDestination) {
            NavigationLink(value: NavigationDestination.library) {
                Label(
                    NavigationDestination.library.label,
                    systemImage: NavigationDestination.library.systemImage
                )
            }

            Section("Collections") {
                ForEach(collections) { collection in
                    let destination = NavigationDestination.collection(
                        collection.id, collection.name
                    )
                    NavigationLink(value: destination) {
                        Label(
                            collection.name,
                            systemImage: destination.systemImage
                        )
                    }
                }
            }
        }
        .navigationTitle("Retroview")
        .frame(idealWidth: 100)
    }
}

struct GalleryScreen: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedDestination: NavigationDestination = .library
    @State private var showingImport = false

    var body: some View {
        #if os(visionOS)
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
        #else
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
        #endif
    }

    @ViewBuilder
    private var navigationDestinationView: some View {
        switch selectedDestination {
        case .library:
            LibraryView()
        case .collection(let id, _):
            if let collection = fetchCollection(id: id) {
                CollectionView(collection: collection)
            } else {
                ContentUnavailableView(
                    "Collection Not Found",
                    systemImage: "folder.badge.questionmark",
                    description: Text(
                        "The selected collection could not be found")
                )
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

#Preview("Gallery") {
    GalleryScreen()
        .withPreviewContainer()
        .frame(width: 1200, height: 800)
}
