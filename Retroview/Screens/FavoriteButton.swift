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
    @State private var isFavorite = false

    var body: some View {
        Button {
            Task {
                await toggleFavorite()
            }
        } label: {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.title2)
                .foregroundStyle(.white)
                .shadow(radius: 2)
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.plain)
        .task {
            // Check initial favorite status
            await checkFavoriteStatus()
        }
    }

    private func checkFavoriteStatus() async {
        let descriptor = FetchDescriptor(
            predicate: ModelPredicates.Collection.favorites)
        guard let favorites = try? modelContext.fetch(descriptor).first else {
            return
        }
        isFavorite = favorites.hasCard(card)
    }

    private func toggleFavorite() async {
        let descriptor = FetchDescriptor(
            predicate: ModelPredicates.Collection.favorites)
        guard let favorites = try? modelContext.fetch(descriptor).first else {
            return
        }

        if isFavorite {
            favorites.removeCard(card)
        } else {
            favorites.addCard(card)
        }

        isFavorite.toggle()
        try? modelContext.save()
    }
}

extension View {
    func withHoverEffect(
        @ViewBuilder content: @escaping (Bool) -> some View
    ) -> some View {
        modifier(
            HoverEffectModifier(content: { isHovered in
                AnyView(content(isHovered))
            }))
    }
}
