//
//  InteractiveCardModifier.swift
//  Retroview
//
//  Created by Adam Schuster on 12/1/24.
//

import SwiftData
import SwiftUI

struct InteractiveCardModifier: ViewModifier {
    let card: CardSchemaV1.StereoCard
    let currentCollection: CollectionSchemaV1.Collection?
    @State private var showingNewCollectionSheet = false
    let onSelect: ((CardSchemaV1.StereoCard) -> Void)?

    func body(content: Content) -> some View {
        content
            .onTapGesture {
                onSelect?(card)
            }
            .withCardInteraction { isActive in
                if isActive {
                    CardHoverOverlay(
                        card: card,
                        viewModel: StereoCardViewModel(stereoCard: card),
                        showingNewCollectionSheet: $showingNewCollectionSheet,
                        currentCollection: currentCollection
                    )
                }
            }
            .draggable(card)
            .contextMenu {
                CollectionMenuContent(
                    showNewCollectionSheet: $showingNewCollectionSheet,
                    card: card,
                    currentCollection: currentCollection
                )
            }
            .sheet(isPresented: $showingNewCollectionSheet) {
                NewCollectionSheet(card: card)
            }
    }
}
