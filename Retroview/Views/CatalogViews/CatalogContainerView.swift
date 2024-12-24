//
//  CatalogContainerView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/22/24.
//

import SwiftUI
import SwiftData

struct CatalogContainerView<Item: CatalogItem>: View {
    @State private var selectedItem: Item?
    @State private var selectedCard: CardSchemaV1.StereoCard?
    @State private var navigationPath = NavigationPath()
    
    let title: String
    let icon: String
    let sortDescriptor: SortDescriptor<Item>

    var body: some View {
        NavigationSplitView {
            CatalogListView(
                sortBy: sortDescriptor,
                selection: $selectedItem,
                title: title,
                icon: icon
            )
            .platformNavigationTitle(title)
        } detail: {
            if let item = selectedItem {
                NavigationStack(path: $navigationPath) {
                    BaseCatalogDetailView(item: item)
                        .navigationTitle(item.name)
                }
            } else {
                ContentUnavailableView {
                    Label("No \(title.dropLast()) Selected", systemImage: icon)
                } description: {
                    Text("Select a \(title.dropLast().lowercased()) to see their cards")
                }
            }
        }
    }
}
