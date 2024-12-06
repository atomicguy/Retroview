//
//  CollectionRow.swift
//  Retroview
//
//  Created by Adam Schuster on 12/2/24.
//

import SwiftUI

struct GroupingRow<T: CardGrouping>: View {
    let collection: T

    var body: some View {
        HStack {
            Text(collection.name)
                .font(.system(.headline, design: .serif))
            Spacer()
            Text("\(collection.cards.count)")
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
    }
}

#Preview("Grouping Row") {
    CardPreviewContainer { _ in
        GroupingRow(
            collection: SubjectSchemaV1.Subject(
                name: "Sample Subject"
            )
        )
        .padding()
    }
}
