//
//  CollectionRow.swift
//  Retroview
//
//  Created by Adam Schuster on 12/2/24.
//

import SwiftUI

struct CollectionRow<T: CardCollection>: View {
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

#Preview("Collection Row") {
    CardPreviewContainer { _ in
        CollectionRow(
            collection: SubjectSchemaV1.Subject(
                name: "Sample Subject"
            )
        )
        .padding()
    }
}
