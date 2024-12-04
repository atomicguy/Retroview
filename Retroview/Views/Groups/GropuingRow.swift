//
//  CollectionRow.swift
//  Retroview
//
//  Created by Adam Schuster on 12/2/24.
//

import SwiftUI

struct GropuingRow<T: CardGrouping>: View {
    let collection: T

    var body: some View {
        HStack {
            Text(collection.name)
            Spacer()
            Text("\(collection.cards.count)")
                .foregroundStyle(.secondary)
                .monospacedDigit()
        }
    }
}

#Preview("Grouping Row") {
    CardPreviewContainer { _ in
        GropuingRow(
            collection: SubjectSchemaV1.Subject(
                name: "Sample Subject"
            )
        )
        .padding()
    }
}
