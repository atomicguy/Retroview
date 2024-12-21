//
//  MainView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/20/24.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @Query(sort: \CollectionSchemaV1.Collection.name) private var collections: [CollectionSchemaV1.Collection]
    @State private var selectedDestination: AppDestination?
    @State private var columnVisibility = NavigationSplitViewVisibility.automatic
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            Sidebar(selectedDestination: $selectedDestination)
        } detail: {
            NavigationStack {
                contentView
            }
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch selectedDestination {
        case .none, .library:
            LibraryGridView()
        case .subjects:
            Text("Subjects View")  // TODO: Create SubjectsView
        case .authors:
            Text("Authors View")   // TODO: Create AuthorsView
        case let .collection(id, _):
            if let collection = collections.first(where: { $0.id == id }) {
                CollectionView(collection: collection)
            } else {
                ContentUnavailableView("Collection Not Found",
                    systemImage: "exclamationmark.triangle")
            }
        }
    }
}
