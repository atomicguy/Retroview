//
//  ThumbnailSelectableView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/20/24.
//

import SwiftData
import SwiftUI

#if os(visionOS)
    struct ThumbnailHoverEffect: CustomHoverEffect {
        func body(content: Content) -> some CustomHoverEffect {
            content.hoverEffect { effect, isActive, proxy in
                effect.animation(.easeInOut(duration: 0.2)) {
                    // Modify the overlay's opacity based on hover state
                    $0.opacity(isActive ? 1 : 0)
                }
            }
        }
    }
#endif

struct ThumbnailSelectableView: View {
    let card: CardSchemaV1.StereoCard
    let isSelected: Bool
    let onSelect: () -> Void
    let onDoubleClick: () -> Void

    @State private var isHovering = false
    @State private var isGlancing = false
    @State private var tapping = false
    @State private var showActionMenu = false

    var body: some View {
        ZStack {
            // Main thumbnail content
            ThumbnailView(card: card)
                .overlay {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.brown, lineWidth: 3)
                    }
                }
                .overlay(alignment: .bottom) {
                    ThumbnailOverlay(
                        card: card,
                        isVisible: shouldShowOverlay
                    )
                    #if os(visionOS)
                        .hoverEffect(ThumbnailHoverEffect())
                    #endif
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .contentShape(RoundedRectangle(cornerRadius: 12))
                .onHover { hovering in
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isHovering = hovering
                    }
                }
//                #if os(visionOS)
//                    .hoverEffect(.highlight)
//                    .scaleEffect(tapping ? 0.95 : 1)
//                    .gesture(
//                        LongPressGesture(minimumDuration: 0.5)
//                            .onEnded { _ in
//                                showActionMenu = true
//                                withAnimation(.bouncy(duration: 0.5)) {
//                                    tapping = false
//                                }
//                            }
//                            .simultaneously(
//                                with: DragGesture(minimumDistance: 0)
//                                    .onChanged({ value in
//                                        withAnimation(.smooth(duration: 0.2)) {
//                                            tapping = true
//                                        }
//                                    })
//                                    .onEnded({ value in
//                                        withAnimation(.bouncy(duration: 0.5)) {
//                                            tapping = false
//                                        }
//                                    }))
//                    )
//                #endif
                .platformInteraction(
                    InteractionConfig(
                        onTap: onSelect,
                        onDoubleTap: onDoubleClick,
                        onSecondaryAction: {
                            AnyView(
                                CardActionMenu(
                                    card: card,
                                    showDirectMenu: .constant(true)
                                )
                            )
                        },
                        isSelected: isSelected
                    )
                )
        }
        .popover(isPresented: $showActionMenu) {
            CardActionMenu(card: card, showDirectMenu: .constant(true))
        }
    }

    private var shouldShowOverlay: Bool {
        #if os(macOS)
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
