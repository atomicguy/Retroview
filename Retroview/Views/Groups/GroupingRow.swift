//
//  CollectionRow.swift
//  Retroview
//
//  Created by Adam Schuster on 12/2/24.
//

import SwiftUI
import SwiftData

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
    let container = try! PreviewDataManager.shared.container()
    let subjectDescriptor = FetchDescriptor<SubjectSchemaV1.Subject>()
    let subject = try! container.mainContext.fetch(subjectDescriptor).first!
    
    return GroupingRow(collection: subject)
        .padding()
        .withPreviewData()
}
