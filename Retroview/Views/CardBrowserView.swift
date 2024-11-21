//
//  CardBrowserView.swift
//  Retroview
//
//  Created by Adam Schuster on 11/20/24.
//

import SwiftData
import SwiftUI

struct CardBrowserView: View {
    let cards: [CardSchemaV1.StereoCard]
    @Binding var selectedCards: Set<CardSchemaV1.StereoCard>
    let onCreateGroup: () -> Void

    var body: some View {
        VStack {
            toolbar
            ScrollView {
                LazyVGrid(columns: [.init(.adaptive(minimum: 300))]) {
                    ForEach(cards) { card in
                        UnifiedCardView(card: card)
                            .overlay(selectionOverlay(for: card))
                            .onTapGesture {
                                toggleSelection(card)
                            }
                    }
                }
                .padding()
            }
        }
    }

    private var toolbar: some View {
        HStack {
            Text("\(selectedCards.count) selected")
            Spacer()
            if !selectedCards.isEmpty {
                Button("Create Group", action: onCreateGroup)
            }
        }
        .padding()
    }

    private func selectionOverlay(for card: CardSchemaV1.StereoCard)
        -> some View
    {
        Group {
            if selectedCards.contains(card) {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(.blue, lineWidth: 2)
                    .overlay(
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.blue)
                            .padding(8),
                        alignment: .topTrailing
                    )
            }
        }
    }

    private func toggleSelection(_ card: CardSchemaV1.StereoCard) {
        if selectedCards.contains(card) {
            selectedCards.remove(card)
        } else {
            selectedCards.insert(card)
        }
    }
}

#Preview {
    CardBrowserView(
        cards: PreviewHelper.shared.previewCards,
        selectedCards: .constant([]),
        onCreateGroup: {}
    )
    .modelContainer(PreviewHelper.shared.modelContainer)
}
