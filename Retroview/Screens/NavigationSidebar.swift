//
//  NavigationSidebar.swift
//  Retroview
//
//  Created by Adam Schuster on 11/28/24.
//

import SwiftData
import SwiftUI

struct NavigationSidebar: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var selectedDestination: NavigationDestination
    @Query(sort: \CollectionSchemaV1.Collection.name) private var collections:
        [CollectionSchemaV1.Collection]

    // Platform-specific selection state
    @State private var listSelection: String?

    var body: some View {
        List(
            selection: Binding(
                get: { listSelection },
                set: { newValue in
                    listSelection = newValue
                    if let newValue {
                        // Convert selection ID back to destination
                        if newValue == NavigationDestination.library.id {
                            selectedDestination = .library
                        } else if newValue == NavigationDestination.subjects.id {
                            selectedDestination = .subjects
                        } else if let uuid = UUID(uuidString: newValue) {
                            // Find matching collection
                            if let collection = collections.first(where: {
                                $0.id == uuid
                            }) {
                                selectedDestination = .collection(
                                    uuid, collection.name
                                )
                            }
                        }
                    }
                }
            )
        ) {
            NavigationLink(value: NavigationDestination.library.id) {
                Label(
                    NavigationDestination.library.label,
                    systemImage: NavigationDestination.library.systemImage
                )
            }

            NavigationLink(value: NavigationDestination.subjects.id) {
                Label(
                    NavigationDestination.subjects.label,
                    systemImage: NavigationDestination.subjects.systemImage
                )
            }

            Section("Collections") {
                ForEach(collections) { collection in
                    let destination = NavigationDestination.collection(
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
        .navigationTitle("Retroview")
        .frame(idealWidth: 100)
        .onChange(of: selectedDestination) { _, newValue in
            // Update list selection when destination changes externally
            updateListSelection(for: newValue)
        }
        .onAppear {
            // Set initial selection
            updateListSelection(for: selectedDestination)
        }
    }

    private func updateListSelection(for destination: NavigationDestination) {
        switch destination {
        case .library:
            listSelection = NavigationDestination.library.id
        case .subjects:
            listSelection = NavigationDestination.subjects.id
        case let .collection(id, _):
            listSelection = id.uuidString
        }
    }
}

// Add identifiable support to NavigationDestination
extension NavigationDestination {
    var id: String {
        switch self {
        case .library:
            return "library"
        case .subjects:
            return "subjects"
        case let .collection(id, _):
            return id.uuidString
        }
    }
}
