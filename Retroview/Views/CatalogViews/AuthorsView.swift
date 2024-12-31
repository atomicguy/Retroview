//
//  AuthorsView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/22/24.
//

import SwiftData
import SwiftUI

struct AuthorsView: View {
    @Binding var navigationPath: NavigationPath
    @State private var sortState = CatalogSortState<AuthorSchemaV1.Author>()

    @Query(sort: [SortDescriptor(\AuthorSchemaV1.Author.name)])
    private var authors: [AuthorSchemaV1.Author]

    var sortedAuthors: [AuthorSchemaV1.Author] {
        authors.sorted { first, second in
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
        List(sortedAuthors) { author in
            NavigationLink(value: author) {
                VStack(alignment: .leading) {
                    Text(author.name)
                        .font(.headline)
                    Text("\(author.cards.count) cards")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Authors")
        .toolbar {
            ToolbarItem {
                CatalogSortButton(sortState: sortState)
            }
        }
    }
}

#Preview("Authors View") {
    NavigationStack {
        AuthorsView(navigationPath: .constant(NavigationPath()))
            .withPreviewStore()
    }
}
