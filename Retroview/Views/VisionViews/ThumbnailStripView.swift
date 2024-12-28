//
//  ThumbnailStripView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/27/24.
//

#if os(visionOS)
import SwiftUI
import SwiftData

struct ThumbnailGalleryStrip: View {
    let cards: [CardSchemaV1.StereoCard]
    @Binding var selectedIndex: Int
    @State private var scrollPosition: Int?
    
    // Constants for layout
    private let thumbnailWidth: CGFloat = 120
    private let thumbnailHeight: CGFloat = 60
    private let spacing: CGFloat = 12
    private let horizontalPadding: CGFloat = 16
    
    private var stripWidth: CGFloat {
        let contentWidth = CGFloat(cards.count) * thumbnailWidth +
            CGFloat(max(0, cards.count - 1)) * spacing
        return contentWidth + (horizontalPadding * 2)
    }
    
    var body: some View {
        GeometryReader { geometry in
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
                .scrollPosition(id: $scrollPosition)
                .onChange(of: selectedIndex) { _, newValue in
                    withAnimation {
                        scrollPosition = newValue
                        proxy.scrollTo(newValue, anchor: .center)
                    }
                }
            }
            .frame(width: min(stripWidth, geometry.size.width - 32))
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .frame(maxWidth: .infinity)
        }
        .frame(height: thumbnailHeight + 20)
    }
}

#Preview("Thumbnail Strip - Multiple Cards") {
    let container = try! PreviewDataManager.shared.container()
    let descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
    let cards = try! container.mainContext.fetch(descriptor)
    
    return ThumbnailGalleryStrip(cards: cards, selectedIndex: .constant(1))
        .withPreviewStore()
        .environment(\.imageLoader, CardImageLoader())
        .padding()
}

#Preview("Thumbnail Strip - Single Card") {
    guard let card = PreviewDataManager.shared.singleCard({ card in
        card.imageFrontId != nil
    }) else {
        return Text("No suitable preview card found")
    }
    
    return ThumbnailGalleryStrip(cards: [card], selectedIndex: .constant(0))
        .withPreviewStore()
        .environment(\.imageLoader, CardImageLoader())
        .padding()
}

#Preview("Thumbnail Strip - Three Cards (First Selected)") {
    let container = try! PreviewDataManager.shared.container()
    let descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
    let cards = Array(try! container.mainContext.fetch(descriptor).prefix(3))
    
    return ThumbnailGalleryStrip(cards: cards, selectedIndex: .constant(0))
        .withPreviewStore()
        .environment(\.imageLoader, CardImageLoader())
        .padding()
}

#Preview("Thumbnail Strip - Three Cards (Last Selected)") {
    let container = try! PreviewDataManager.shared.container()
    let descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
    let cards = Array(try! container.mainContext.fetch(descriptor).prefix(3))
    
    return ThumbnailGalleryStrip(cards: cards, selectedIndex: .constant(2))
        .withPreviewStore()
        .environment(\.imageLoader, CardImageLoader())
        .padding()
}
#endif
