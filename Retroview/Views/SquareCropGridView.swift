//
//  SquareCropGridView.swift
//  Retroview
//
//  Created by Adam Schuster on 11/26/24.
//

import SwiftUI
import SwiftData

struct SquareCropGridView: View {
    let cards: [CardSchemaV1.StereoCard]
    @Binding var selectedCard: CardSchemaV1.StereoCard?
    
    private let columns = [
        GridItem(.adaptive(minimum: 250, maximum: 300), spacing: 16),
        GridItem(.adaptive(minimum: 250, maximum: 300), spacing: 16),
        GridItem(.adaptive(minimum: 250, maximum: 300), spacing: 16)
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(cards) { card in
                SquareCropView(card: card)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedCard = card
                    }
                    .overlay {
                        if selectedCard?.uuid == card.uuid {
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.accentColor, lineWidth: 3)
                        }
                    }
            }
        }
        .padding(16)
    }
}

// MARK: - Preview Provider

#Preview("Square Crop Grid") {
    SquareCropGridView(
        cards: PreviewHelper.shared.previewCards,
        selectedCard: .constant(nil)
    )
    .frame(width: 800, height: 600)
    .modelContainer(PreviewHelper.shared.modelContainer)
}
