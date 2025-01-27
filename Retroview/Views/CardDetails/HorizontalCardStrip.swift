//
//  HorizontalCardStrip.swift
//  Retroview
//
//  Created by Adam Schuster on 1/25/25.
//

import SwiftData
import SwiftUI

#if os(macOS)
    import AppKit
#endif

struct HorizontalCardStrip: View {
    let cards: [CardSchemaV1.StereoCard]
    let initialIndex: Int
    let onIndexChanged: (Int) -> Void

    @State private var currentIndex: Int
    @GestureState private var dragOffset: CGFloat = 0
    @SceneStorage("cardScrollOffset") private var persistedOffset: Double = 0

    private let cardSpacing: CGFloat = 32
    private let velocityThreshold: CGFloat = 200
    private let dragThreshold: CGFloat = 50

    init(
        cards: [CardSchemaV1.StereoCard],
        initialCard: CardSchemaV1.StereoCard,
        onIndexChanged: @escaping (Int) -> Void
    ) {
        self.cards = cards
        self.initialIndex =
            cards.firstIndex(where: { $0.id == initialCard.id }) ?? 0
        self.onIndexChanged = onIndexChanged
        _currentIndex = State(initialValue: initialIndex)
    }

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 32) {
                    ForEach(Array(cards.enumerated()), id: \.element.id) {
                        index, card in
                        CardDetailView(card: card)
                            .frame(width: geometry.size.width)
                            .opacity(index == currentIndex ? 1 : 0.3)
                    }
                }
                .offset(x: calculateTotalOffset(geometry))
                .animation(
                    .spring(response: 0.35, dampingFraction: 0.8),
                    value: currentIndex
                )
                .animation(
                    .spring(response: 0.35, dampingFraction: 0.8),
                    value: dragOffset)
            }
            .gesture(dragGesture(geometry))
            .scrollDisabled(true)
        }
        .onChange(of: currentIndex) { _, newIndex in
            onIndexChanged(newIndex)
        }
    }

    private func calculateTotalOffset(_ geometry: GeometryProxy) -> CGFloat {
        let cardWidth = geometry.size.width + cardSpacing
        return -CGFloat(currentIndex) * cardWidth + dragOffset
    }

    private func dragGesture(_ geometry: GeometryProxy) -> some Gesture {
        DragGesture(minimumDistance: 10)
            .updating($dragOffset) { value, state, _ in
                state = value.translation.width
            }
            .onEnded { value in
                let velocity = value.predictedEndLocation.x - value.location.x

                if abs(velocity) > velocityThreshold {
                    if velocity > 0 && currentIndex > 0 {
                        currentIndex -= 1
                    } else if velocity < 0 && currentIndex < cards.count - 1 {
                        currentIndex += 1
                    }
                } else if abs(value.translation.width) > dragThreshold {
                    if value.translation.width > 0 && currentIndex > 0 {
                        currentIndex -= 1
                    } else if value.translation.width < 0
                        && currentIndex < cards.count - 1
                    {
                        currentIndex += 1
                    }
                }
            }
    }

    private func navigateToPrevious() {
        guard currentIndex > 0 else { return }
        currentIndex -= 1
    }

    private func navigateToNext() {
        guard currentIndex < cards.count - 1 else { return }
        currentIndex += 1
    }
}

#Preview("Horizontal Card Strip") {
    NavigationStack {
        CardsPreviewContainer(count: 5) { cards in
            HorizontalCardStrip(cards: cards, initialCard: cards[0]) { _ in }
        }
    }
}
