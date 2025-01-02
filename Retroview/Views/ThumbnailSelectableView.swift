//
//  ThumbnailSelectableView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/20/24.
//

import SwiftData
import SwiftUI

struct ThumbnailSelectableView: View {
    let card: CardSchemaV1.StereoCard
    let isSelected: Bool
    let onSelect: () -> Void
    let onDoubleClick: () -> Void

    @State private var isHovering = false
    @State private var isGlancing = false

    var body: some View {
        ZStack {
            // Main thumbnail content
            ThumbnailView(card: card)
                .overlay {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.teal, lineWidth: 3)
                    }
                }
                .overlay(alignment: .bottom) {
                    ThumbnailOverlay(
                        card: card,
                        isVisible: shouldShowOverlay
                    )
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .contentShape(Rectangle())
                .onHover { hovering in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        #if os(visionOS)
                            isGlancing = hovering
                        #else
                            isHovering = hovering
                        #endif
                    }
                }
                #if os(visionOS)
                    .hoverEffect(.highlight)
                #endif
                .platformTapAction(
                    singleTapAction: onSelect,
                    doubleTapAction: onDoubleClick
                )

            // Tap exclusion zone for menu
            if shouldShowOverlay {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Rectangle()
                            .fill(.clear)
                            .frame(width: 60, height: 60)
                            .allowsHitTesting(true)
                    }
                }
            }
        }
    }

    private var shouldShowOverlay: Bool {
        #if os(visionOS)
            return isGlancing
        #elseif os(macOS)
            return isHovering
        #else
            return true
        #endif
    }
}

#Preview("Selectable Thumbnail View") {
    // Create a mock card for preview
    let mockCard = CardSchemaV1.StereoCard(
        uuid: UUID(),
        imageFrontId: "sample-image-id",
        titles: [TitleSchemaV1.Title(text: "Sample Title")],
        authors: [AuthorSchemaV1.Author(name: "John Doe")]
    )

    return VStack {
        ThumbnailSelectableView(
            card: mockCard,
            isSelected: false,
            onSelect: {},
            onDoubleClick: {}
        )
        .frame(width: 300, height: 200)

        ThumbnailSelectableView(
            card: mockCard,
            isSelected: true,
            onSelect: {},
            onDoubleClick: {}
        )
        .frame(width: 300, height: 200)
    }
    .environment(\.imageLoader, CardImageLoader())
}
