//
//  StereoGalleryStrip.swift
//  Retroview
//
//  Created by Adam Schuster on 12/29/24.
//

import SwiftUI

struct StereoGalleryStrip: View {
    let cards: [CardSchemaV1.StereoCard]
    @Binding var selectedIndex: Int
    @State private var scrollPosition: Int?
    
    // Constants for layout
    private let thumbnailWidth: CGFloat = 120
    private let thumbnailHeight: CGFloat = 60
    private let spacing: CGFloat = 12
    private let horizontalPadding: CGFloat = 16
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: spacing) {
                    ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                        ThumbnailView(card: card)
                            .frame(width: thumbnailWidth, height: thumbnailHeight)
                            .overlay {
                                if index == selectedIndex {
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(.white, lineWidth: 2)
                                }
                            }
                            .id(index)
                            .onTapGesture {
                                withAnimation {
                                    selectedIndex = index
                                }
                            }
                    }
                }
                .padding(.horizontal, horizontalPadding)
            }
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .frame(maxWidth: .infinity)
            .onChange(of: selectedIndex) { _, newValue in
                withAnimation {
                    proxy.scrollTo(newValue, anchor: .center)
                }
            }
        }
        .frame(height: thumbnailHeight + 20)
    }
}

#Preview("Gallery Strip - Multiple Cards") {
    CardsPreviewContainer(count: 5) { cards in
        StereoGalleryStrip(cards: cards, selectedIndex: .constant(1))
            .padding()
    }
}

#Preview("Gallery Strip - Single Card") {
    CardPreviewContainer { card in
        StereoGalleryStrip(cards: [card], selectedIndex: .constant(0))
            .padding()
    }
}

#Preview("Gallery Strip - Three Cards (First Selected)") {
    CardsPreviewContainer(count: 3) { cards in
        StereoGalleryStrip(cards: cards, selectedIndex: .constant(0))
            .padding()
    }
}

#Preview("Gallery Strip - Three Cards (Last Selected)") {
    CardsPreviewContainer(count: 3) { cards in
        StereoGalleryStrip(cards: cards, selectedIndex: .constant(2))
            .padding()
    }
}

#Preview("Gallery Strip - With Filtered Cards") {
    CardsPreviewContainer(count: 5, where: { card in
        card.imageFrontId != nil && card.leftCrop != nil
    }) { cards in
        StereoGalleryStrip(cards: cards, selectedIndex: .constant(0))
            .padding()
    }
}

#Preview("Gallery Strip - Empty State") {
    StereoGalleryStrip(cards: [], selectedIndex: .constant(0))
        .padding()
}
