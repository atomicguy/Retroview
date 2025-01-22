//
//  CatalogGridView.swift
//  Retroview
//
//  Created by Adam Schuster on 1/12/25.
//

import SwiftData
import SwiftUI

struct GroupGridView<T: GroupItem>: View {
    @Binding var navigationPath: NavigationPath
    @State private var searchText = ""
    @State private var sortState = CatalogSortState<T>()
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
    
    private var filteredAndSortedItems: [T] {
            let filtered =
                searchText.isEmpty
                ? items
                : items.filter { item in
                    item.name.localizedCaseInsensitiveContains(searchText)
                }

            return filtered.sorted { first, second in
                switch sortState.option {
                case .alphabetical:
                    if sortState.ascending {
                        return first.name < second.name
                    } else {
                        return first.name > second.name
                    }
                case .cardCount:
                    if sortState.ascending {
                        return first.cards.count < second.cards.count
                    } else {
                        return first.cards.count > second.cards.count
                    }
                }
            }
        }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                SearchBar(text: $searchText)
                GroupSortButton(sortState: sortState)
            }
            .padding(.horizontal)
            .padding(.vertical, 8)

            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(filteredAndSortedItems) { item in
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
                        .buttonStyle(.plain)
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
        .platformNavigationTitle("\(title) (\(filteredAndSortedItems.count))")
        .searchable(text: $searchText, prompt: "Search \(title)")
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
        GroupGridView<SubjectSchemaV1.Subject>(
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
        GroupGridView<AuthorSchemaV1.Author>(
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
        GroupGridView<DateSchemaV1.Date>(
            title: "Dates",
            navigationPath: .constant(NavigationPath()),
            sortDescriptor: SortDescriptor(\DateSchemaV1.Date.text)
        )
        .withPreviewStore()
        .frame(width: 600, height: 400)
    }
}
