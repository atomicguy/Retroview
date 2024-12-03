//
//  StereoBrowser.swift
//  Retroview
//
//  Created by Adam Schuster on 12/1/24.
//

import SwiftData
import SwiftUI

#if os(visionOS)
    struct StereoBrowser: View {
        let cards: [CardSchemaV1.StereoCard]
        @Binding var selectedCard: CardSchemaV1.StereoCard
        @Binding var isVisible: Bool
        let currentCollection: CollectionSchemaV1.Collection?

        var body: some View {
            ZStack(alignment: .topLeading) {
                Button {
                    withAnimation(.spring) {
                        isVisible = false
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.primary)
                        .padding(12)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .padding(20)
                .zIndex(1)

                VStack(spacing: 0) {
                    StyleStereoView(
                        card: selectedCard
                    )
                    .id(selectedCard.uuid)
                    .frame(maxHeight: .infinity)

                    CenteredThumbnailStrip(
                        cards: cards,
                        selectedCard: selectedCard,
                        onSelect: { card in
                            withAnimation(.spring) {
                                selectedCard = card
                            }
                        }
                    )
                }
            }
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if value.translation.width > 100 {
                            navigateCards(direction: -1)
                        } else if value.translation.width < -100 {
                            navigateCards(direction: 1)
                        }
                    }
            )
            .gesture(
                MagnificationGesture()
                    .onEnded { scale in
                        if scale < 0.8 {
                            withAnimation(.spring) {
                                isVisible = false
                            }
                        }
                    }
            )
        }

        private func navigateCards(direction: Int) {
            guard let currentIndex = cards.firstIndex(of: selectedCard) else { return }

            let newIndex = (currentIndex + direction + cards.count) % cards.count
            withAnimation(.spring) {
                selectedCard = cards[newIndex]
            }
        }
    }

    #Preview {
        CardsPreviewContainer { cards in
            StereoBrowser(
                cards: cards,
                selectedCard: .constant(cards[0]),
                isVisible: .constant(true),
                currentCollection: nil
            )
        }
    }
#endif
