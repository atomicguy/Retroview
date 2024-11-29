//
//  FavoriteButton.swift
//  Retroview
//
//  Created by Adam Schuster on 11/28/24.
//

import SwiftData
import SwiftUI

struct HoverEffectModifier: ViewModifier {
    @State private var isHovered = false
    let content: (Bool) -> AnyView

    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { _ in
                    self.content(isHovered)
                        .allowsHitTesting(true)
                }
            }
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHovered = hovering
                }
            }
    }
}

struct FavoriteButton: View {
    @Environment(\.modelContext) private var modelContext
    let card: CardSchemaV1.StereoCard

    private var favorites: CollectionSchemaV1.Collection? {
        try? modelContext.fetch(CollectionDefaults.favoritesDescriptor()).first
    }

    private var isFavorite: Bool {
        guard let favorites = favorites else { return false }
        return favorites.hasCard(card)
    }

    var body: some View {
        Button {
            toggleFavorite()
        } label: {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.title2)
                .foregroundStyle(.white)
                .shadow(radius: 2)
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.plain)
    }

    private func toggleFavorite() {
        guard let favorites = favorites else { return }

        withAnimation(.bouncy) {
            if isFavorite {
                favorites.removeCard(card)
            } else {
                favorites.addCard(card)
            }
            try? modelContext.save()
        }
    }
}

extension View {
    func withHoverEffect<Content: View>(
        @ViewBuilder content: @escaping (Bool) -> Content
    ) -> some View {
        modifier(
            HoverEffectModifier(content: { isHovered in
                AnyView(content(isHovered))
            }))
    }
}
