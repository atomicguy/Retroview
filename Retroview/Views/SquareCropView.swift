//
//  SquareCropView.swift
//  Retroview
//
//  Created by Adam Schuster on 11/26/24.
//

import CoreGraphics
import SwiftData
import SwiftUI

struct SquareCropView: View {
    let card: CardSchemaV1.StereoCard
    let currentCollection: CollectionSchemaV1.Collection?
    let onSelect: ((CardSchemaV1.StereoCard) -> Void)?
    
    var body: some View {
        CroppedCardView(card: card)
            .modifier(InteractiveCardModifier(
                card: card,
                currentCollection: currentCollection,
                onSelect: onSelect
            ))
    }
}

#Preview("Single Card") {
    CardPreviewContainer { card in
        SquareCropView(
            card: card,
            currentCollection: nil,
            onSelect: { _ in }
        )
        .frame(width: 300)
        .padding()
    }
}

#Preview("Card in Collection") {
    CardPreviewContainer { card in
        SquareCropView(
            card: card,
            currentCollection: CollectionSchemaV1.Collection.preview,
            onSelect: { _ in }
        )
        .frame(width: 300)
        .padding()
    }
}

#Preview("Grid Layout") {
    CardPreviewContainer { card in
        LazyVGrid(
            columns: [
                GridItem(.adaptive(minimum: 250, maximum: 300))
            ],
            spacing: 10
        ) {
            ForEach(0..<4) { _ in
                SquareCropView(
                    card: card,
                    currentCollection: nil,
                    onSelect: { _ in }
                )
            }
        }
        .padding()
    }
}
