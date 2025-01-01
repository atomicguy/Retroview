//
//  SelectableThumbnailView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/20/24.
//

import SwiftData
import SwiftUI

struct SelectableThumbnailView: View {
    let card: CardSchemaV1.StereoCard
    let isSelected: Bool
    let onSelect: () -> Void
    let onDoubleClick: () -> Void
    @State private var isHovering = false
    
    var body: some View {
        ThumbnailView(card: card)
            .overlay {
                // Selection indicator
                if isSelected {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.brown, lineWidth: 3)
                }
            }
            .overlay {
                // Buttons overlay with clipped gradient
                VStack {
                    Spacer()
                    HStack {
                        FavoriteButton(card: card)
                            .opacity(buttonOpacity)
                        
                        Spacer()
                        
                        CollectionMenuButton(card: card)
                            .opacity(menuButtonOpacity)
                    }
                    .padding(8)
                }
                .background {
                    LinearGradient(
                        colors: [.clear, .black.opacity(0.3)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            #if os(visionOS)
            .hoverEffect(.highlight)
            .onTapGesture(perform: onDoubleClick)
            #else
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHovering = hovering
                }
            }
            .gesture(TapGesture(count: 2).onEnded(onDoubleClick))
            .simultaneousGesture(TapGesture(count: 1).onEnded(onSelect))
            #endif
            .contentShape(Rectangle())
    }
    
    private var isFavorite: Bool {
        card.collections.contains { $0.name == CollectionDefaults.favoritesName }
    }
    
    private var buttonOpacity: Double {
        #if os(visionOS)
        // On visionOS, only show if favorited or hovering
        isFavorite ? 1 : (isHovering ? 1 : 0)
        #elseif os(iOS)
        // On iOS/iPadOS, always show but dimmed unless favorited
        isFavorite ? 1 : 0.6
        #else
        // On macOS, show when favorited or hovering
        isFavorite ? 1 : (isHovering ? 1 : 0)
        #endif
    }
    
    private var menuButtonOpacity: Double {
        #if os(visionOS)
        // Only show on hover
        isHovering ? 1 : 0
        #elseif os(iOS)
        // Always show but dimmed
        0.6
        #else
        // Show on hover
        isHovering ? 1 : 0
        #endif
    }
}

// Custom glow effect for visionOS
#if os(visionOS)
    private struct GlowEffect: ViewModifier {
        let isSelected: Bool

        func body(content: Content) -> some View {
            content.overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.white.opacity(0.8), lineWidth: 2)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
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

#Preview("Selectable Thumbnail View") {
    // Create a mock card for preview
    let mockCard = CardSchemaV1.StereoCard(
        uuid: UUID(),
        imageFrontId: "sample-image-id",
        titles: [TitleSchemaV1.Title(text: "Sample Title")],
        authors: [AuthorSchemaV1.Author(name: "John Doe")]
    )

    return VStack {
        SelectableThumbnailView(
            card: mockCard,
            isSelected: false,
            onSelect: {},
            onDoubleClick: {}
        )
        .frame(width: 300, height: 200)

        SelectableThumbnailView(
            card: mockCard,
            isSelected: true,
            onSelect: {},
            onDoubleClick: {}
        )
        .frame(width: 300, height: 200)
    }
    .frame(width: 400)
    .environment(\.imageLoader, CardImageLoader())
}
