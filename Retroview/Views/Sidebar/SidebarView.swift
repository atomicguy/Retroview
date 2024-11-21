//
//  SidebarView.swift
//  Retroview
//
//  Created by Adam Schuster on 11/20/24.
//

import SwiftData
import SwiftUI

struct SidebarView: View {
    @Binding var filter: CardFilter
    let groups: [CardGroupSchemaV1.Group]
    let selectedGroup: CardGroupSchemaV1.Group?
    let onGroupSelect: (CardGroupSchemaV1.Group) -> Void

    @Query private var authors: [AuthorSchemaV1.Author]
    @Query private var dates: [DateSchemaV1.Date]
    @Query private var subjects: [SubjectSchemaV1.Subject]

    var body: some View {
        List(selection: Binding.constant(selectedGroup)) {
            Section("Filters") {
                TextField("Search", text: $filter.searchText)

                Picker("Author", selection: $filter.selectedAuthor) {
                    Text("Any").tag(AuthorSchemaV1.Author?.none)
                    ForEach(authors) { author in
                        Text(author.name).tag(Optional(author))
                    }
                }

                Picker("Date", selection: $filter.selectedDate) {
                    Text("Any").tag(DateSchemaV1.Date?.none)
                    ForEach(dates) { date in
                        Text(date.text).tag(Optional(date))
                    }
                }

                Picker("Subject", selection: $filter.selectedSubject) {
                    Text("Any").tag(SubjectSchemaV1.Subject?.none)
                    ForEach(subjects) { subject in
                        Text(subject.name).tag(Optional(subject))
                    }
                }
            }

            Section("Groups") {
                ForEach(groups) { group in
                    HStack {
                        Text(group.name)
                        Spacer()
                        Text("\(group.cards.count)")
                            .foregroundStyle(.secondary)
                    }
                    .tag(group)
                    .onTapGesture {
                        onGroupSelect(group)
                    }
                }
            }
        }
    }
}

#Preview("Sidebar") {
    SidebarView(
        filter: .constant(CardFilter()),
        groups: PreviewHelper.shared.previewGroups,
        selectedGroup: nil,
        onGroupSelect: { _ in }
    )
    .frame(width: 250)
    .modelContainer(PreviewHelper.shared.modelContainer)
}
