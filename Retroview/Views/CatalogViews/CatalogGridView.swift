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
    @State private var searchText = ""
    @Query private var items: [T]
    private let title: String

    init(
        title: String,
        navigationPath: Binding<NavigationPath>,
        sortDescriptor: SortDescriptor<T>,
        predicate: Predicate<T>? = nil
    ) {
        self.title = title
        _navigationPath = navigationPath

        // Configure Query with sort and predicate
        let queryPredicate = predicate
        _items = Query(filter: queryPredicate, sort: [sortDescriptor])
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
        VStack(spacing: 0) {
            // Search bar
            SearchBar(text: $searchText)
                .padding(.horizontal)
                .padding(.vertical, 8)

            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(filteredItems) { item in
                        NavigationLink(value: item) {
                            StackThumbnailView(item: item)
                                .aspectRatio(1, contentMode: .fit)
                                .frame(minHeight: 300)
                                .withAutoThumbnailUpdate(item)
                                .if(item is CollectionSchemaV1.Collection) {
                                    view in
                                    view.withCollectionContextMenu(
                                        item as! CollectionSchemaV1.Collection
                                    )
                                }
                        }
                        .aspectRatio(1, contentMode: .fit)
                        .platformInteraction(
                            InteractionConfig(
                                showHoverEffects: true
                            )
                        )
                    }

                }
                .padding(PlatformEnvironment.Metrics.defaultPadding)
            }
        }
        .platformNavigationTitle("\(title) (\(filteredItems.count))")
    }

    private var filteredItems: [T] {
        items.filter {
            searchText.isEmpty
                || $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }
}

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content)
        -> some View
    {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

#Preview("Catalog Grid View - Subjects") {
    NavigationStack {
        CatalogGridView<SubjectSchemaV1.Subject>(
            title: "Subjects",
            navigationPath: .constant(NavigationPath()),
            sortDescriptor: SortDescriptor(\SubjectSchemaV1.Subject.name)
        )
        .withPreviewStore()
        .frame(width: 600, height: 400)
    }
}

#Preview("Catalog Grid View - Authors") {
    NavigationStack {
        CatalogGridView<AuthorSchemaV1.Author>(
            title: "Authors",
            navigationPath: .constant(NavigationPath()),
            sortDescriptor: SortDescriptor(\AuthorSchemaV1.Author.name)
        )
        .withPreviewStore()
        .frame(width: 600, height: 400)
    }
}

#Preview("Catalog Grid View - Dates") {
    NavigationStack {
        CatalogGridView<DateSchemaV1.Date>(
            title: "Dates",
            navigationPath: .constant(NavigationPath()),
            sortDescriptor: SortDescriptor(\DateSchemaV1.Date.text)
        )
        .withPreviewStore()
        .frame(width: 600, height: 400)
    }
}
