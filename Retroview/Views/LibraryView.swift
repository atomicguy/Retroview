//
//  LibraryView.swift
//  Retroview
//
//  Created by Adam Schuster on 11/26/24.
//

import SwiftData
import SwiftUI

struct LibraryView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \CardSchemaV1.StereoCard.uuid) private var cards:
        [CardSchemaV1.StereoCard]
    @State private var selectedCard: CardSchemaV1.StereoCard?

    var body: some View {
        BrowseLayout(
            listContent: { EmptyView() },
            gridContent: {
                CardGridView(
                    cards: cards,
                    selectedCard: $selectedCard,
                    currentCollection: nil,
                    title: "Library"
                )
            },
            selectedCard: $selectedCard
        )
    }
}

// MARK: - Preview Provider

#Preview("Library") {
    LibraryView()
        .withPreviewContainer()
        .frame(width: 1200, height: 800)
}
