//
//  StereoSpatialViewer.swift
//  Retroview
//
//  Created by Adam Schuster on 12/1/24.
//

import SwiftUI
import SwiftData

struct StereoSpatialViewer: View {
    let cards: [CardSchemaV1.StereoCard]
    @State private var selectedCard: CardSchemaV1.StereoCard?
    @State private var gridVisible = true
    let currentCollection: CollectionSchemaV1.Collection?
    
    var body: some View {
        ZStack {
            if gridVisible {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 250, maximum: 300))], spacing: 10) {
                        ForEach(cards) { card in
                            ViewerSquareCropView(
                                card: card,
                                currentCollection: currentCollection
                            )
                            .onTapGesture {
                                withAnimation(.spring) {
                                    selectedCard = card
                                    gridVisible = false
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            
            if let selected = selectedCard {
                VStack(spacing: 0) {
                    ViewerSquareCropView(
                        card: selected,
                        currentCollection: currentCollection
                    )
                    .id(selected.uuid)
                    .frame(maxHeight: .infinity)
                    
                    CenteredThumbnailStrip(
                        cards: cards,
                        selectedCard: selected,
                        onSelect: { card in
                            withAnimation(.spring) {
                                selectedCard = card
                            }
                        }
                    )
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
                                    gridVisible = true
                                    selectedCard = nil
                                }
                            }
                        }
                )
            }
        }
    }
    
    private func navigateCards(direction: Int) {
        guard let current = selectedCard,
              let currentIndex = cards.firstIndex(of: current) else { return }
              
        let newIndex = (currentIndex + direction + cards.count) % cards.count
        withAnimation(.spring) {
            selectedCard = cards[newIndex]
        }
    }
}



#Preview {
    CardsPreviewContainer { cards in
        StereoSpatialViewer(
            cards: cards,
            currentCollection: nil
        )
    }
}
