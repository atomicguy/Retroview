//
//  CatalogSortOptions.swift
//  Retroview
//
//  Created by Assistant on 12/30/24.
//

import SwiftData
import SwiftUI

enum CatalogSortOption: String, CaseIterable {
    case alphabetical = "Alphabetical"
    case cardCount = "Number of Cards"

    var icon: String {
        switch self {
        case .alphabetical: "textformat.abc"
        case .cardCount: "square.stack.3d.up"
        }
    }
}

@Observable
class CatalogSortState<T: CatalogItem>: Equatable {
    var option: CatalogSortOption
    var ascending: Bool

    init(option: CatalogSortOption = .alphabetical, ascending: Bool = true) {
        self.option = option
        self.ascending = ascending
    }

    var sortDescriptor: SortDescriptor<T> {
        switch option {
        case .alphabetical:
            return SortDescriptor(
                \T.name, order: ascending ? .forward : .reverse)
        case .cardCount:
            return SortDescriptor(
                \T.cards.count, order: ascending ? .forward : .reverse)
        }
    }

    var orderIcon: String {
        ascending ? "arrow.up" : "arrow.down"
    }

    var orderText: String {
        ascending ? "Ascending" : "Descending"
    }

    static func == (lhs: CatalogSortState<T>, rhs: CatalogSortState<T>) -> Bool
    {
        lhs.option == rhs.option && lhs.ascending == rhs.ascending
    }
}

