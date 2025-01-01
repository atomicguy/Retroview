//
//  SearchManager.swift
//  Retroview
//
//  Created by Adam Schuster on 12/31/24.
//

import Foundation
import SwiftData
import SwiftUI

@Observable
class SearchManager {
    let modelContext: ModelContext
    var searchText = ""
    private(set) var totalCount = 0

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    var predicate: Predicate<CardSchemaV1.StereoCard>? {
        guard !searchText.isEmpty else { return nil }

        return #Predicate<CardSchemaV1.StereoCard> { card in
            card.titles.contains(where: {
                $0.text.localizedStandardContains(searchText)
            })
        }
    }

    var filteredCards: [CardSchemaV1.StereoCard] {
        var descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
        if let predicate = predicate {
            descriptor.predicate = predicate
        }
        descriptor.sortBy = [SortDescriptor(\.uuid)]

        return (try? modelContext.fetch(descriptor)) ?? []
    }

    func updateTotalCount(context: ModelContext) {
        var descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
        if let predicate = predicate {
            descriptor.predicate = predicate
        }
        totalCount = (try? context.fetchCount(descriptor)) ?? 0
    }
}
