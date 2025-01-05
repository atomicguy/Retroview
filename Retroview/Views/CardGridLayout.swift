//
//  CardGridGroup.swift
//  Retroview
//
//  Created by Adam Schuster on 12/20/24.
//

import SwiftData
import SwiftUI

struct CardGridLayout: View {
    let cards: [CardSchemaV1.StereoCard]
    @Binding var selectedCard: CardSchemaV1.StereoCard?
    @Binding var navigationPath: NavigationPath
    let onCardSelected: (CardSchemaV1.StereoCard) -> Void

    private var columns: [GridItem] {
        [
            GridItem(
                .adaptive(
                    minimum: PlatformEnvironment.Metrics.gridMinWidth,
                    maximum: PlatformEnvironment.Metrics.gridMaxWidth
                ), spacing: 20)
        ]
    }

    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: columns,
                spacing: PlatformEnvironment.Metrics.gridSpacing
            ) {
                ForEach(cards) { card in
                    ThumbnailSelectableView(
                        card: card,
                        isSelected: card.id == selectedCard?.id,
                        onSelect: { selectedCard = card },
                        onDoubleClick: {
                            navigationPath.append(
                                CardStackDestination.stack(
                                    cards: cards,
                                    initialCard: card
                                ))
                        }
                    )
                }
            }
            .padding(PlatformEnvironment.Metrics.defaultPadding)
        }
        .platformToolbar {
            EmptyView()
        } trailing: {
            #if os(visionOS)
                StereoGalleryButton(
                    cards: cards,
                    selectedCard: selectedCard
                )
            #endif
        }
    }
}

#Preview("Card Grid Layout") {
    let container = try! PreviewDataManager.shared.container()
    let descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
    let cards = try! container.mainContext.fetch(descriptor)

    return NavigationStack {
        CardGridLayout(
            cards: cards,
            selectedCard: .constant(cards.first),
            navigationPath: .constant(NavigationPath()),
            onCardSelected: { _ in }
        )
        .withPreviewStore()
        .environment(\.imageLoader, CardImageLoader())
        .frame(width: 1024, height: 600)
        .serifNavigationTitle("Preview Grid")
    }
}

#Preview("Empty Grid") {
    NavigationStack {
        CardGridLayout(
            cards: [],
            selectedCard: .constant(nil),
            navigationPath: .constant(NavigationPath()),
            onCardSelected: { _ in }
        )
        .withPreviewStore()
        .environment(\.imageLoader, CardImageLoader())
        .frame(width: 1024, height: 600)
        .serifNavigationTitle("Empty Grid")
    }
}
