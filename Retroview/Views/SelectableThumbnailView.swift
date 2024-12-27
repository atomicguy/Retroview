//
//  SelectableThumbnailView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/20/24.
//

import SwiftUI
import SwiftData

struct SelectableThumbnailView: View {
    let card: CardSchemaV1.StereoCard
    let isSelected: Bool
    let onSelect: () -> Void
    let onDoubleClick: () -> Void
    
    var body: some View {
        ThumbnailView(card: card)
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.teal, lineWidth: 3)
                }
            }
            .gesture(
                TapGesture(count: 2).onEnded(onDoubleClick)
            )
            .simultaneousGesture(
                TapGesture(count: 1).onEnded(onSelect)
            )
            .contentShape(Rectangle())
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
        SelectableThumbnailView(
            card: mockCard,
            isSelected: false,
            onSelect: { },
            onDoubleClick: { }
        )
        .frame(width: 300, height: 200)
        
        SelectableThumbnailView(
            card: mockCard,
            isSelected: true,
            onSelect: { },
            onDoubleClick: { }
        )
        .frame(width: 300, height: 200)
    }
    .environment(\.imageLoader, CardImageLoader())
}
