//
//  StereoGalleryStrip.swift
//  Retroview
//
//  Created by Adam Schuster on 12/29/24.
//

import SwiftUI

// MARK: - StereoGalleryStrip
struct StereoGalleryStrip: View {
    let cards: [CardSchemaV1.StereoCard]
    @Binding var selectedIndex: Int
    let onSelectionChanged: (CardSchemaV1.StereoCard) -> Void

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: GalleryLayoutConstants.spacing) {
                    ForEach(Array(cards.enumerated()), id: \.element.id) {
                        index, card in
                        GalleryThumbnail(
                            card: card,
                            isSelected: index == selectedIndex
                        )
                        .contentShape(Rectangle())
                        #if os(visionOS)
                            .hoverEffect()
                            .glowEffect(isSelected: index == selectedIndex)
                        #endif
                        .onTapGesture {
                            withAnimation(.bouncy) {
                                selectedIndex = index
                                onSelectionChanged(card)
                            }
                        }
                        .id(index)
                    }
                }
                .padding(.horizontal, GalleryLayoutConstants.padding)
            }
            .onChange(of: selectedIndex) { _, newIndex in
                withAnimation(.easeInOut(duration: 0.3)) {
                    proxy.scrollTo(newIndex, anchor: .center)
                }
            }
        }
        .frame(height: GalleryLayoutConstants.thumbnailHeight + 20)
        .background(.ultraThinMaterial)
        .clipShape(
            RoundedRectangle(cornerRadius: GalleryLayoutConstants.cornerRadius))
    }
}

// MARK: - GalleryThumbnail
struct GalleryThumbnail: View {
    let card: CardSchemaV1.StereoCard
    let isSelected: Bool

    private var thumbnailWidth: CGFloat {
        isSelected
            ? GalleryLayoutConstants.thumbnailWidth
            : GalleryLayoutConstants.thumbnailWidth / 2
    }

    var body: some View {
        if isSelected {
            // Show full thumbnail when selected
            ThumbnailView(card: card)
                .frame(
                    width: GalleryLayoutConstants.thumbnailWidth,
                    height: GalleryLayoutConstants.thumbnailHeight
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: GalleryLayoutConstants.cornerRadius))
        } else {
            // Show left half of thumbnail when not selected
            ThumbnailView(card: card)
                .frame(
                    width: GalleryLayoutConstants.thumbnailWidth,
                    height: GalleryLayoutConstants.thumbnailHeight
                )
                .frame(
                    width: GalleryLayoutConstants.thumbnailWidth / 2,
                    height: GalleryLayoutConstants.thumbnailHeight
                )
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: GalleryLayoutConstants.cornerRadius))
        }
    }
}

// MARK: - Vision Effects
#if os(visionOS)
    struct GlowEffect: ViewModifier {
        let isSelected: Bool

        func body(content: Content) -> some View {
            content
                .overlay {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.white.opacity(0.8), lineWidth: 2)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.white.opacity(0.2))
                            )
                    }
                }
        }
    }

    extension View {
        func glowEffect(isSelected: Bool) -> some View {
            modifier(GlowEffect(isSelected: isSelected))
        }
    }
#endif

// MARK: - Previews

#Preview("Gallery Strip - Interactive") {
    CardsPreviewContainer(count: 5) { cards in
        StatefulPreviewWrapper(0) { selectedIndex in
            StereoGalleryStrip(
                cards: cards,
                selectedIndex: selectedIndex,
                onSelectionChanged: { card in
                    print("Selected card: \(card.uuid)")
                }
            )
            .padding()
        }
    }
}

#Preview("Gallery Strip - Single Card") {
    CardPreviewContainer { card in
        StereoGalleryStrip(
            cards: [card],
            selectedIndex: .constant(0),
            onSelectionChanged: { _ in }
        )
        .padding()
    }
}

#Preview("Gallery Strip - With Filtered Cards") {
    CardsPreviewContainer(
        count: 5,
        where: { card in
            card.imageFrontId != nil && card.leftCrop != nil
        }
    ) { cards in
        StatefulPreviewWrapper(0) { selectedIndex in
            StereoGalleryStrip(
                cards: cards,
                selectedIndex: selectedIndex,
                onSelectionChanged: { card in
                    print("Selected card: \(card.uuid)")
                }
            )
            .padding()
        }
    }
}

#Preview("Gallery Strip - Empty State") {
    StereoGalleryStrip(
        cards: [],
        selectedIndex: .constant(0),
        onSelectionChanged: { _ in }
    )
    .padding()
}

// Helper for stateful previews
private struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State private var value: Value
    let content: (Binding<Value>) -> Content

    init(_ value: Value, content: @escaping (Binding<Value>) -> Content) {
        self._value = State(initialValue: value)
        self.content = content
    }

    var body: some View {
        content($value)
    }
}
