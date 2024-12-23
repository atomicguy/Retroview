//
//  MainView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/20/24.
//

import SwiftData
import SwiftUI

struct MainView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CollectionSchemaV1.Collection.name) private var collections: [CollectionSchemaV1.Collection]
    @State private var selectedDestination: AppDestination?
    @State private var columnVisibility = NavigationSplitViewVisibility.automatic
    @State private var libraryCardCount: Int = 0
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            Sidebar(selectedDestination: $selectedDestination)
                .platformNavigationTitle("Retroview", displayMode: .inline)
        } detail: {
            NavigationStack {
                contentView
            }
        }
        .task {
            await updateLibraryCardCount()
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch selectedDestination {
        case .none, .library:
            LibraryGridView()
                .platformNavigationTitle("Library (\(libraryCardCount) cards)")
        case .subjects:
            SubjectsView()
        case .authors:
            AuthorsView()
        case let .collection(id, _):
            if let collection = collections.first(where: { $0.id == id }) {
                CollectionView(collection: collection)
            } else {
                ContentUnavailableView(
                    "Collection Not Found",
                    systemImage: "exclamationmark.triangle"
                )
            }
        }
    }
    
    private func updateLibraryCardCount() async {
        do {
            let descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
            libraryCardCount = try modelContext.fetchCount(descriptor)
        } catch {
            libraryCardCount = 0
            print("Failed to fetch library card count: \(error)")
        }
    }
}
