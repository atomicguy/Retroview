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
final class SearchManager {
    var searchText = ""
    private(set) var totalCount: Int = 0

    var predicate: Predicate<CardSchemaV1.StereoCard>? {
        guard !searchText.isEmpty else { return nil }

        return #Predicate<CardSchemaV1.StereoCard> { card in
            // Search in titles
            card.titles.contains { title in
                title.text.localizedStandardContains(searchText)
            }
                // Search in subjects
                || card.subjects.contains { subject in
                    subject.name.localizedStandardContains(searchText)
                }
                // Search in authors
                || card.authors.contains { author in
                    author.name.localizedStandardContains(searchText)
                }
                // Search in dates
                || card.dates.contains { date in
                    date.text.localizedStandardContains(searchText)
                }
        }
    }

    @MainActor
    func updateTotalCount(context: ModelContext) {
        var descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
        if let searchPredicate = predicate {
            descriptor.predicate = searchPredicate
        }
        totalCount = (try? context.fetchCount(descriptor)) ?? 0
    }
}
