//
//  CatalogListView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/22/24.
//

import SwiftData
import SwiftUI

struct CatalogListView<Item: CatalogItem>: View {
    @Query private var items: [Item]
    @Binding var selection: Item?
    let title: String
    let icon: String

    init(
        sortBy: SortDescriptor<Item>,
        selection: Binding<Item?>,
        title: String,
        icon: String
    ) {
        _items = Query(sort: [sortBy])
        _selection = selection
        self.title = title
        self.icon = icon
    }

    var body: some View {
        List(items, selection: $selection) { item in
            NavigationLink(value: item) {
                VStack(alignment: .leading) {
                    Text(item.name)
                        .font(.headline)
                    Text("\(item.cards.count) cards")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("\(title) (\(items.count))")
    }
}


