//
//  CatalogGridView.swift
//  Retroview
//
//  Created by Adam Schuster on 1/12/25.
//

import SwiftData
import SwiftUI

@MainActor
struct GroupGridView<T: GroupItem>: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var navigationPath: NavigationPath
    @State private var searchText = ""
    @State private var sortState = GroupSortState<T>()
    @State private var loadedItems = [T]()
    @State private var isLoadingMore = false
    private let pageSize = 50
    private let title: String

    init(
        title: String,
        navigationPath: Binding<NavigationPath>,
        sortDescriptor: SortDescriptor<T>
    ) {
        self.title = title
        self._navigationPath = navigationPath
        self.sortState = GroupSortState(option: .alphabetical)
    }

    private let columns = [
        GridItem(
            .adaptive(
                minimum: PlatformEnvironment.Metrics.gridMinWidth,
                maximum: PlatformEnvironment.Metrics.gridMaxWidth
            ), spacing: PlatformEnvironment.Metrics.gridSpacing)
    ]

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
                    ForEach(loadedItems) { item in
                        NavigationLink(value: item) {
                            StackThumbnailView(item: item)
                                .aspectRatio(1, contentMode: .fit)
                                .frame(minHeight: 300)
                                .withAutoThumbnailUpdate(item)
                        }
                        .buttonStyle(.plain)
                    }

                    if !isLoadingMore {
                        Color.clear.onAppear {
                            loadMoreItems()
                        }
                    }
                }
                .padding(PlatformEnvironment.Metrics.defaultPadding)
            }
        }
        .platformNavigationTitle("\(title) (\(loadedItems.count))")
        .onAppear {
            loadInitialItems()
        }
        .onChange(of: searchText) {
            loadInitialItems()
        }
    }

    @MainActor
    private func createDescriptor(offset: Int = 0) -> FetchDescriptor<T> {
        var descriptor = FetchDescriptor<T>()
        descriptor.fetchOffset = offset
        descriptor.fetchLimit = pageSize

        if !searchText.isEmpty {
            descriptor.predicate = #Predicate<T> { item in
                item.name.localizedStandardContains(searchText)
            }
        }

        return descriptor
    }

    @MainActor
    private func loadInitialItems() {
        do {
            let descriptor = createDescriptor()
            loadedItems = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to load initial items: \(error)")
        }
    }

    @MainActor
    private func loadMoreItems() {
        guard !isLoadingMore else { return }
        isLoadingMore = true
        defer { isLoadingMore = false }

        do {
            let descriptor = createDescriptor(offset: loadedItems.count)
            let newItems = try modelContext.fetch(descriptor)
            loadedItems.append(contentsOf: newItems)
        } catch {
            print("Failed to load more items: \(error)")
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
