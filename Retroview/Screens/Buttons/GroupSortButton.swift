//
//  GroupSortButton.swift
//  Retroview
//
//  Created by Adam Schuster on 1/21/25.
//

import SwiftUI

struct GroupSortButton<T: GroupItem>: View {
    @Bindable var sortState: GroupSortState<T>

    var body: some View {
        Menu {
            ForEach(GroupSortOptions.allCases, id: \.self) { option in
                Button {
                    sortState.option = option
                } label: {
                    HStack {
                        Image(
                            systemName: sortState.option == option
                                ? "circle.fill" : "circle")
                        Text(option.rawValue)
                    }
                }
            }

            Divider()

            Button {
                sortState.ascending.toggle()
            } label: {
                Label(sortState.orderText, systemImage: sortState.orderIcon)
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .font(.title2)
        }
        .buttonStyle(.plain)
    }
}

#Preview("Catalog Sort Button - Subjects") {
    NavigationStack {
        GroupSortButton(
            sortState: GroupSortState<SubjectSchemaV1.Subject>()
        )
        .withPreviewStore()
        .frame(width: 44, height: 44)
    }
}

#Preview("Catalog Sort Button - Authors") {
    NavigationStack {
        GroupSortButton(sortState: GroupSortState<AuthorSchemaV1.Author>())
            .withPreviewStore()
            .frame(width: 44, height: 44)
    }
}
