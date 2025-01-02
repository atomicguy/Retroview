//
//  CardDetailStackView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/31/24.
//

import SwiftData
import SwiftUI

struct CardDetailStackView: View {
    let cards: [CardSchemaV1.StereoCard]
    let initialCard: CardSchemaV1.StereoCard

    @State private var currentIndex: Int
    @State private var offset: CGFloat = 0

    // Centralized animation parameters
    private let transitionAnimation = Animation.spring(
        response: 0.3,
        dampingFraction: 0.8
    )

    private let bounceAnimation = Animation.spring(
        response: 0.3,
        dampingFraction: 0.8
    )

    private let bounceDelay = 0.1
    private let bounceDistance: CGFloat = 50
    private let edgeResistance: CGFloat = 0.2
    private let dragThresholdPercentage: CGFloat = 0.25

    init(cards: [CardSchemaV1.StereoCard], initialCard: CardSchemaV1.StereoCard)
    {
        self.cards = cards
        self.initialCard = initialCard
        _currentIndex = State(
            initialValue: cards.firstIndex(where: { $0.id == initialCard.id })
                ?? 0)
    }

    var body: some View {
        GeometryReader { geometry in
            CardDetailView(card: cards[currentIndex])
                .id(cards[currentIndex].id)
                .offset(x: offset)
                .gesture(dragGesture(geometry: geometry))
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigation) {
                Button {
                    navigatePrevious()
                } label: {
                    Label("Previous", systemImage: "chevron.left")
                }
                .disabled(currentIndex <= 0)

                Button {
                    navigateNext()
                } label: {
                    Label("Next", systemImage: "chevron.right")
                }
                .disabled(currentIndex >= cards.count - 1)
            }
        }
    }

    private func dragGesture(geometry: GeometryProxy) -> some Gesture {
        DragGesture()
            .onChanged { value in
                if (currentIndex == 0 && value.translation.width > 0)
                    || (currentIndex == cards.count - 1
                        && value.translation.width < 0)
                {
                    offset = value.translation.width * edgeResistance
                } else {
                    offset = value.translation.width
                }
            }
            .onEnded { value in
                let threshold = geometry.size.width * dragThresholdPercentage

                if value.translation.width > threshold && currentIndex > 0 {
                    withAnimation(transitionAnimation) {
                        currentIndex -= 1
                        offset = 0
                    }
                } else if value.translation.width < -threshold
                    && currentIndex < cards.count - 1
                {
                    withAnimation(transitionAnimation) {
                        currentIndex += 1
                        offset = 0
                    }
                } else {
                    withAnimation(transitionAnimation) {
                        offset = 0
                    }
                }
            }
    }

    private func navigatePrevious() {
        if currentIndex > 0 {
            withAnimation(transitionAnimation) {
                currentIndex -= 1
            }
        } else {
            // Bounce effect at start
            withAnimation(bounceAnimation) {
                offset = bounceDistance
            }
            withAnimation(bounceAnimation.delay(bounceDelay)) {
                offset = 0
            }
        }
    }

    private func navigateNext() {
        if currentIndex < cards.count - 1 {
            withAnimation(transitionAnimation) {
                currentIndex += 1
            }
        } else {
            // Bounce effect at end
            withAnimation(bounceAnimation) {
                offset = -bounceDistance
            }
            withAnimation(bounceAnimation.delay(bounceDelay)) {
                offset = 0
            }
        }
    }
}

#Preview("Card Detail Stack View") {
    NavigationStack {
        CardsPreviewContainer(
            count: 5,
            where: { card in
                // Only show cards with images and crops
                card.imageFrontId != nil && card.leftCrop != nil
            }
        ) { cards in
            CardDetailStackView(
                cards: cards,
                initialCard: cards[cards.count / 2]
            )
            .environment(\.imageLoader, CardImageLoader())
        }
    }
}
