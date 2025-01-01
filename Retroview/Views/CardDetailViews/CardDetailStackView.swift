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
    @State private var navigationDirection: NavigationDirection = .none
    @GestureState private var dragOffset: CGFloat = 0

    enum NavigationDirection {
        case forward
        case backward
        case none
    }

    init(cards: [CardSchemaV1.StereoCard], initialCard: CardSchemaV1.StereoCard)
    {
        self.cards = cards
        self.initialCard = initialCard
        _currentIndex = State(
            initialValue: cards.firstIndex(where: { $0.id == initialCard.id })
                ?? 0
        )
    }

    var body: some View {
        GeometryReader { geometry in
            let dragGesture = DragGesture()
                .updating($dragOffset) { value, state, _ in
                    state = value.translation.width
                }
                .onEnded { value in
                    let dragThreshold = geometry.size.width * 0.25
                    let dragAmount = value.translation.width

                    if dragAmount > dragThreshold && currentIndex > 0 {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            navigationDirection = .backward
                            currentIndex -= 1
                        }
                    } else if dragAmount < -dragThreshold
                        && currentIndex < cards.count - 1
                    {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            navigationDirection = .forward
                            currentIndex += 1
                        }
                    }
                }

            CardDetailView(card: cards[currentIndex])
                .id(cards[currentIndex].uuid)
                .offset(x: dragOffset)
                .gesture(dragGesture)
                .transition(cardTransition)
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigation) {
                Button {
                    guard currentIndex > 0 else { return }
                    withAnimation {
                        navigationDirection = .backward
                        currentIndex -= 1
                    }
                } label: {
                    Label("Previous", systemImage: "chevron.left")
                }
                .disabled(currentIndex <= 0)

                Button {
                    guard currentIndex < cards.count - 1 else { return }
                    withAnimation {
                        navigationDirection = .forward
                        currentIndex += 1
                    }
                } label: {
                    Label("Next", systemImage: "chevron.right")
                }
                .disabled(currentIndex >= cards.count - 1)
            }
        }
    }

    private var cardTransition: AnyTransition {
        switch navigationDirection {
        case .forward:
            return .asymmetric(
                insertion: .move(edge: .trailing),
                removal: .move(edge: .leading)
            )
        case .backward:
            return .asymmetric(
                insertion: .move(edge: .leading),
                removal: .move(edge: .trailing)
            )
        case .none:
            return .identity
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
