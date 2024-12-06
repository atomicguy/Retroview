//
//  CardCollection.swift
//  Retroview
//
//  Created by Adam Schuster on 12/2/24.
//

import Foundation
import SwiftData
import SwiftUI

protocol CardGrouping: Identifiable, Hashable {
    var name: String { get }
    var cards: [CardSchemaV1.StereoCard] { get }
}

// MARK: - Collection Type Conformance

extension SubjectSchemaV1.Subject: CardGrouping {
    func hash(into hasher: inout Hasher) {
        hasher.combine(persistentModelID)
    }
}

extension AuthorSchemaV1.Author: CardGrouping {
    func hash(into hasher: inout Hasher) {
        hasher.combine(persistentModelID)
    }
}

extension CollectionSchemaV1.Collection: CardGrouping {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    var cards: [CardSchemaV1.StereoCard] {
        guard let context = modelContext else { return [] }
        return fetchCards(context: context)
    }
}

#Preview("Card Grouping Preview") {
    CardPreviewContainer { _ in
        GroupingPreview(
            collection: SubjectSchemaV1.Subject(
                name: "Sample Subject"
            ), isSelected: false
        )
        .frame(width: 300)
        .padding()
    }
}
