//
//  CatalogGridView.swift
//  Retroview
//
//  Created by Adam Schuster on 1/12/25.
//

import SwiftData
import SwiftUI

struct CatalogGridView<T: CatalogItem>: View {
    @Binding var navigationPath: NavigationPath
    @State private var sortState = CatalogSortState<T>()
    @State private var searchText = ""
    @Query private var items: [T]
    private let title: String

    init(
        title: String,
        navigationPath: Binding<NavigationPath>,
        sortDescriptor: SortDescriptor<T>
    ) {
        self.title = title
        _navigationPath = navigationPath
        _items = Query(sort: [sortDescriptor])
    }

    private var columns: [GridItem] {
        [
            GridItem(
                .adaptive(
                    minimum: PlatformEnvironment.Metrics.gridMinWidth,
                    maximum: PlatformEnvironment.Metrics.gridMaxWidth),
                spacing: PlatformEnvironment.Metrics.gridSpacing)
        ]
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(filteredAndSortedItems) { item in
                    NavigationLink(value: item) {
                        StackThumbnailView(item: item)
                            .frame(minHeight: 300)
                            .focusable()
                    }
                }
            }
            .padding(PlatformEnvironment.Metrics.defaultPadding)
        }
    }
    private var filteredAndSortedItems: [T] {
        items.filter {
            searchText.isEmpty
                || $0.name.localizedCaseInsensitiveContains(searchText)
        }.sorted {
            $0.name < $1.name
        }
    }
}
