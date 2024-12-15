//
//  GalleryScreen.swift
//  Retroview
//
//  Created by Assistant on 11/29/24.
//

import SwiftData
import SwiftUI

struct GalleryScreen: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedDestination: AppDestination = .library
    @State private var showingImport = false
    @State private var showingTransfer = false

    var body: some View {
        defaultLayout
    }

    private var defaultLayout: some View {
        NavigationSplitView {
            NavigationSidebar(selectedDestination: $selectedDestination)
                .platformNavigationTitle("Retroview")
        } detail: {
            navigationDestinationView
                .platformToolbar {
                    EmptyView()
                } trailing: {
                    HStack {
                        toolbarButton(
                            title: "Import Cards",
                            systemImage: "square.and.arrow.down"
                        ) {
                            showingImport = true
                        }

                        toolbarButton(
                            title: "Database Transfer",
                            systemImage: "arrow.up.arrow.down.circle"
                        ) {
                            showingTransfer = true
                        }

                        #if DEBUG
                            DebugMenu()
                        #endif
                    }
                }
        }
        .navigationSplitViewStyle(.automatic)
        .sheet(isPresented: $showingImport) {
            ImportView(modelContext: modelContext)
        }
        .sheet(isPresented: $showingTransfer) {
            DatabaseTransferView()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .ignoresSafeArea(.container, edges: [.leading, .trailing])
        .platformBackground()
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
        case .authors:
            AuthorsView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case let .collection(id, _):
            if let collection = fetchCollection(id: id) {
                CollectionView(collection: collection)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ContentUnavailableView(
                    "Collection Not Found",
                    systemImage: "folder.badge.questionmark",
                    description: Text(
                        "The selected collection could not be found")
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

// Rest of the file remains the same...

// MARK: - Navigation Sidebar
private struct NavigationSidebar: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var selectedDestination: AppDestination
    @Query(sort: \CollectionSchemaV1.Collection.name) private var collections:
        [CollectionSchemaV1.Collection]

    @State private var listSelection: String?

    var body: some View {
        List(
            selection: Binding(
                get: { listSelection },
                set: { newValue in
                    listSelection = newValue
                    if let newValue {
                        updateDestination(for: newValue)
                    }
                }
            )
        ) {
            navigationLinks

            collectionsSection
        }
        .frame(idealWidth: 100)
        .onChange(of: selectedDestination) { _, newValue in
            updateListSelection(for: newValue)
        }
        .onAppear {
            updateListSelection(for: selectedDestination)
        }
    }

    private var navigationLinks: some View {
        Group {
            NavigationLink(value: AppDestination.library.id) {
                Label(
                    AppDestination.library.label,
                    systemImage: AppDestination.library.systemImage
                )
            }

            NavigationLink(value: AppDestination.subjects.id) {
                Label(
                    AppDestination.subjects.label,
                    systemImage: AppDestination.subjects.systemImage
                )
            }

            NavigationLink(value: AppDestination.authors.id) {
                Label(
                    AppDestination.authors.label,
                    systemImage: AppDestination.authors.systemImage
                )
            }
        }
    }

    private var collectionsSection: some View {
        Section("Collections") {
            ForEach(collections) { collection in
                let destination = AppDestination.collection(
                    collection.id, collection.name
                )
                NavigationLink(value: collection.id.uuidString) {
                    Label(
                        collection.name,
                        systemImage: destination.systemImage
                    )
                }
            }
        }
    }

    private func updateDestination(for id: String) {
        if id == AppDestination.library.id {
            selectedDestination = .library
        } else if id == AppDestination.subjects.id {
            selectedDestination = .subjects
        } else if id == AppDestination.authors.id {
            selectedDestination = .authors
        } else if let uuid = UUID(uuidString: id),
            let collection = collections.first(where: { $0.id == uuid })
        {
            selectedDestination = .collection(uuid, collection.name)
        }
    }

    private func updateListSelection(for destination: AppDestination) {
        switch destination {
        case .library:
            listSelection = AppDestination.library.id
        case .subjects:
            listSelection = AppDestination.subjects.id
        case .authors:
            listSelection = AppDestination.authors.id
        case let .collection(id, _):
            listSelection = id.uuidString
        }
    }
}

// MARK: - Preview Support
#Preview("Gallery - Desktop") {
    GalleryScreen()
        .withPreviewData()
        .frame(width: 1200, height: 800)
}

#Preview("Gallery - Vision") {
    GalleryScreen()
        .withPreviewData()
}
