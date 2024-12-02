//
//  ViewerSquareCropView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/1/24.
//

import SwiftData
import SwiftUI

struct ViewerSquareCropView: View {
    let card: CardSchemaV1.StereoCard
    let currentCollection: CollectionSchemaV1.Collection?

    var body: some View {
        CroppedCardView(card: card)
            .contentShape(Rectangle())
    }
}

#Preview("Single Card") {
    CardPreviewContainer { card in
        ViewerSquareCropView(
            card: card,
            currentCollection: nil
        )
        .frame(width: 300)
        .padding()
    }
}

#Preview("Card in Collection") {
    CardPreviewContainer { card in
        ViewerSquareCropView(
            card: card,
            currentCollection: CollectionSchemaV1.Collection.preview
        )
        .frame(width: 300)
        .padding()
    }
}

#Preview("Loading State") {
    CardPreviewContainer { _ in
        let loadingCard = CardSchemaV1.StereoCard(
            uuid: "test",
            imageFrontId: "nonexistent"
        )
        ViewerSquareCropView(
            card: loadingCard,
            currentCollection: nil
        )
        .frame(width: 300)
        .padding()
    }
}
