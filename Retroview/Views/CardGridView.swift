//
//  CardGridView.swift
//  Retroview
//
//  Created by Adam Schuster on 11/29/24.
//

import SwiftUI
import SwiftData

struct CardGridView: View {
    let cards: [CardSchemaV1.StereoCard]
    @Binding var selectedCard: CardSchemaV1.StereoCard?
    let currentCollection: CollectionSchemaV1.Collection?
    let title: String?
    
    private let columns = [
        GridItem(.adaptive(minimum: 250, maximum: 300), spacing: 10)
    ]
    
    var body: some View {
        ScrollView {
            if cards.isEmpty {
                ContentUnavailableView(
                    "No Cards",
                    systemImage: "photo.on.rectangle.angled",
                    description: Text("No cards available to display")
                )
            } else {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(cards) { card in
                        SquareCropView(card: card, currentCollection: currentCollection)
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
                .padding()
            }
        }
        .navigationTitle(title ?? "\(cards.count) Cards")
    }
}

#Preview("Card Grid") {
    CardPreviewContainer { card in
        CardGridView(
            cards: [card],
            selectedCard: .constant(nil),
            currentCollection: nil,
            title: "Test Grid"
        )
        .frame(width: 1200, height: 800)
    }
}
