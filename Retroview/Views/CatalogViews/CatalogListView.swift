//
//  CatalogListView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/31/24.
//

//import SwiftData
//import SwiftUI
//
//struct CatalogListView<T: CatalogItem>: View {
//    @Binding var navigationPath: NavigationPath
//    @State private var sortState = CatalogSortState<T>()
//    @State private var searchText = ""
//
//    @Query private var items: [T]
//    private let title: String
//
//    init(
//        title: String,
//        navigationPath: Binding<NavigationPath>,
//        sortDescriptor: SortDescriptor<T>
//    ) {
//        self.title = title
//        _navigationPath = navigationPath
//        _items = Query(sort: [sortDescriptor])
//    }
//
//    var filteredAndSortedItems: [T] {
//        let filtered =
//            searchText.isEmpty
//            ? items
//            : items.filter { item in
//                item.displayName.localizedCaseInsensitiveContains(searchText)
//            }
//
//        return filtered.sorted { first, second in
//            switch sortState.option {
//            case .alphabetical:
//                if sortState.ascending {
//                    return first.displayName < second.displayName
//                } else {
//                    return first.displayName > second.displayName
//                }
//            case .cardCount:
//                if sortState.ascending {
//                    return first.cards.count < second.cards.count
//                } else {
//                    return first.cards.count > second.cards.count
//                }
//            }
//        }
//    }
//
//    var body: some View {
//        List(filteredAndSortedItems) { item in
//            NavigationLink(value: item) {
//                VStack(alignment: .leading) {
//                    Text(item.displayName)
//                        .font(.headline)
//                    Text("\(item.cards.count) cards")
//                        .font(.caption)
//                        .foregroundStyle(.secondary)
//                }
//            }
//        }
//        .platformNavigationTitle("\(title) (\(filteredAndSortedItems.count))")
//        .searchable(text: $searchText, prompt: "Search \(title)")
//        #if os(macOS)
//            .textFieldStyle(.roundedBorder)
//        #endif
//        .platformToolbar {
//        } trailing: {
//            CatalogSortButton(sortState: sortState)
//        }
//    }
//}
//
//#Preview("Authors") {
//    NavigationStack {
//        CatalogListView<AuthorSchemaV1.Author>(
//            title: "Authors",
//            navigationPath: .constant(NavigationPath()),
//            sortDescriptor: SortDescriptor(\AuthorSchemaV1.Author.name)
//        )
//        .withPreviewStore()
//    }
//}
//
//#Preview("Subjects") {
//    NavigationStack {
//        CatalogListView<SubjectSchemaV1.Subject>(
//            title: "Subjects",
//            navigationPath: .constant(NavigationPath()),
//            sortDescriptor: SortDescriptor(\SubjectSchemaV1.Subject.name)
//        )
//        .withPreviewStore()
//    }
//}
