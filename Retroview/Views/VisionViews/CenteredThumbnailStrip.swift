//
//  CenteredThumbnailStrip.swift
//  Retroview
//
//  Created by Adam Schuster on 12/1/24.
//

import SwiftData
import SwiftUI

struct CenteredThumbnailStrip: View {
    let cards: [CardSchemaV1.StereoCard]
    let selectedCard: CardSchemaV1.StereoCard
    let onSelect: (CardSchemaV1.StereoCard) -> Void
    @Namespace private var animation

    // Constants for layout
    private let thumbnailSize: CGFloat = 80
    private let baseSpacing: CGFloat = 8
    private let selectedScale: CGFloat = 1.5

    // Calculate extra spacing for selected card
    private var spacingForCard: (CardSchemaV1.StereoCard) -> CGFloat {
        { card in
            card.id == selectedCard.id
                ? thumbnailSize + (thumbnailSize * (selectedScale - 1))
                : baseSpacing
        }
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    ZStack {
                        // Base layer of unselected thumbnails
                        LazyHStack(spacing: 0) {
                            Color.clear
                                .frame(
                                    width: max(
                                        0,
                                        (geometry.size.width - thumbnailSize)
                                            / 2))

                            ForEach(cards) { card in
                                if card.id != selectedCard.id {
                                    ThumbnailView(card: card)
                                        .frame(
                                            width: thumbnailSize,
                                            height: thumbnailSize
                                        )
                                        .padding(
                                            .horizontal, spacingForCard(card)
                                        )
                                        .onTapGesture {
                                            withAnimation(.spring) {
                                                onSelect(card)
                                            }
                                        }
                                } else {
                                    Color.clear
                                        .frame(
                                            width: thumbnailSize,
                                            height: thumbnailSize
                                        )
                                        .padding(
                                            .horizontal, spacingForCard(card))
                                }
                            }

                            Color.clear
                                .frame(
                                    width: max(
                                        0,
                                        (geometry.size.width - thumbnailSize)
                                            / 2))
                        }
                        .frame(minWidth: geometry.size.width)

                        // Selected thumbnail on top
                        LazyHStack(spacing: 0) {
                            Color.clear
                                .frame(
                                    width: max(
                                        0,
                                        (geometry.size.width - thumbnailSize)
                                            / 2))

                            ForEach(cards) { card in
                                if card.id == selectedCard.id {
                                    ThumbnailView(card: card, navigationEnabled: false)
                                        .frame(
                                            width: thumbnailSize,
                                            height: thumbnailSize
                                        )
                                        .scaleEffect(selectedScale)
                                        .padding(
                                            .horizontal, spacingForCard(card)
                                        )
                                        .onTapGesture {
                                            withAnimation(.spring) {
                                                onSelect(card)
                                            }
                                        }
                                } else {
                                    Color.clear
                                        .frame(
                                            width: thumbnailSize,
                                            height: thumbnailSize
                                        )
                                        .padding(
                                            .horizontal, spacingForCard(card))
                                }
                            }

                            Color.clear
                                .frame(
                                    width: max(
                                        0,
                                        (geometry.size.width - thumbnailSize)
                                            / 2))
                        }
                        .frame(minWidth: geometry.size.width)
                    }
                }
                .onAppear {
                    scrollToCurrentCard(proxy: proxy)
                }
                .onChange(of: selectedCard) { _, _ in
                    scrollToCurrentCard(proxy: proxy)
                }
            }
        }
        .frame(height: thumbnailSize * selectedScale + baseSpacing * 2)
    }

    private func scrollToCurrentCard(proxy: ScrollViewProxy) {
        withAnimation(.smooth) {
            proxy.scrollTo(selectedCard.id, anchor: .center)
        }
    }
}

//#Preview("Strip of Thumbnails") {
//    let descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
//    let container = try! PreviewDataManager.shared.container()
//    let cards = try! container.mainContext.fetch(descriptor)
//
//    return CenteredThumbnailStrip(
//        cards: cards,
//        selectedCard: cards[0],
//        onSelect: { _ in }
//    )
//    .padding()
//    .background(.regularMaterial)
//    .withPreviewData()
//}

// #Preview ("in situ") {
//    CardsPreviewContainer { cards in
//        StereoSpatialViewer(
//            cards: cards,
//            currentCollection: nil
//        )
//    }
// }

//#Preview("Strip of Thumbnails") {
//    let cards = PreviewStoreManager.shared.previewContainer().allCardSampleData()
//    
//    CenteredThumbnailStrip(
//        cards: cards,
//        selectedCard: cards[0],
//        onSelect: { _ in }
//    )
//    .padding()
//    .background(.regularMaterial)
//}
