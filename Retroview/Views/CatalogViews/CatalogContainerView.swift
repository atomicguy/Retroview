//
//  CatalogContainerView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/22/24.
//

import SwiftUI

struct CatalogContainerView<Item: CatalogItem>: View {
    @State private var selectedItem: Item?
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
            .platformNavigationTitle(
                "\(title) (\(selectedItem?.cards.count ?? 0))")
        } detail: {
            if let item = selectedItem {
                CatalogDetailView(item: item)
            } else {
                ContentUnavailableView {
                    Label("No \(title.dropLast()) Selected", systemImage: icon)
                } description: {
                    Text(
                        "Select a \(title.dropLast().lowercased()) to see their cards"
                    )
                }
            }
        }
    }
}
