//
//  ModernCardListView.swift
//  Retroview
//
//  Created by Adam Schuster on 11/25/24.
//

import SwiftUI
import SwiftData

struct ModernCardListView: View {
    let cards: [CardSchemaV1.StereoCard]
    @Binding var selectedCard: CardSchemaV1.StereoCard?
    
    var body: some View {
        LazyVStack(spacing: 16) {
            ForEach(cards) { card in
                CardListItem(
                    card: card,
                    isSelected: card.uuid == selectedCard?.uuid
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    // Directly set the new selection without toggling
                    selectedCard = card
                }
            }
        }
        .padding(.vertical)
    }
}

private struct CardListItem: View {
    let card: CardSchemaV1.StereoCard
    let isSelected: Bool
    @StateObject private var viewModel: StereoCardViewModel
    
    init(card: CardSchemaV1.StereoCard, isSelected: Bool) {
        self.card = card
        self.isSelected = isSelected
        _viewModel = StateObject(wrappedValue: StereoCardViewModel(stereoCard: card))
    }
    
    var displayTitle: String {
        card.titlePick?.text ?? card.titles.first?.text ?? "Untitled"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Front card image
            StereoCardImageView(viewModel: viewModel, side: "front")
                .frame(maxWidth: .infinity)
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(radius: isSelected ? 8 : 4)
            
            // Title in serif font
            Text(displayTitle)
                .font(.system(.headline, design: .serif))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .padding(.horizontal, 4)
        }
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.background)
                .shadow(radius: isSelected ? 8 : 0)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
        )
    }
}

#Preview("Modern Card List") {
    ModernCardListView(cards: PreviewHelper.shared.previewCards, selectedCard: .constant(nil))
        .modelContainer(PreviewHelper.shared.modelContainer)
}

#Preview("Card List Item") {
    CardListItem(card: PreviewHelper.shared.previewCard, isSelected: true)
        .padding()
        .modelContainer(PreviewHelper.shared.modelContainer)
}
