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

// Preview provider
//#Preview {
//    CardPreviewContainer { card in
//        SelectableThumbnailView(
//            card: card,
//            isSelected: true,
//            onSelect: {},
//            onDoubleClick: {}
//        )
//        .frame(width: 300)
//        .padding()
//    }
//}
