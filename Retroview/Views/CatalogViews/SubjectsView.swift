//
//  SubjectsView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/22/24.
//

import SwiftData
import SwiftUI

struct SubjectsView: View {
    @Binding var navigationPath: NavigationPath
    @State private var sortState = CatalogSortState<SubjectSchemaV1.Subject>()

    @Query(sort: [SortDescriptor(\SubjectSchemaV1.Subject.name)])
    private var subjects: [SubjectSchemaV1.Subject]

    var sortedSubjects: [SubjectSchemaV1.Subject] {
        subjects.sorted { first, second in
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
        List(sortedSubjects) { author in
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
        .navigationTitle("Subjects")
        .toolbar {
            ToolbarItem {
                CatalogSortButton(sortState: sortState)
            }
        }
    }
}

#Preview("Subjects View") {
    NavigationStack {
        SubjectsView(navigationPath: .constant(NavigationPath()))
            .withPreviewStore()
    }
}
