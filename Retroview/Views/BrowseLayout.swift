//
//  BrowseLayout.swift
//  Retroview
//
//  Created by Adam Schuster on 11/29/24.
//

import SwiftData
import SwiftUI

struct BrowseLayout<ListContent: View, GridContent: View>: View {
    let listContent: ListContent
    let gridContent: GridContent
    @Binding var selectedCard: CardSchemaV1.StereoCard?

    private let listWidth: CGFloat = 220
    private let detailWidth: CGFloat = 300

    init(
        @ViewBuilder listContent: () -> ListContent,
        @ViewBuilder gridContent: () -> GridContent,
        selectedCard: Binding<CardSchemaV1.StereoCard?>
    ) {
        self.listContent = listContent()
        self.gridContent = gridContent()
        _selectedCard = selectedCard
    }

    var body: some View {
        HStack(spacing: 0) {
            listContent
                .frame(width: listWidth)

            Divider()

            gridContent
                .frame(maxWidth: .infinity)

            Divider()

            Group {
                if let card = selectedCard {
                    CardContentView(card: card)
                        .id(card.uuid)
                        .transition(.move(edge: .trailing))
                } else {
                    ContentUnavailableView(
                        "No Card Selected",
                        systemImage: "photo.on.rectangle",
                        description: Text("Select a card to view its details")
                    )
                    .transition(.opacity)
                }
            }
            .animation(.smooth, value: selectedCard)
            .frame(width: detailWidth)
        }
    }
}

#Preview("Browse Layout") {
    BrowseLayout(
        listContent: {
            List {
                Text("List Item 1")
                Text("List Item 2")
            }
        },
        gridContent: {
            Text("Grid Content")
        },
        selectedCard: .constant(nil)
    )
    .frame(width: 1200, height: 800)
}
