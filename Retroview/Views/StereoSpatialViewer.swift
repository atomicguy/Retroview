//
//  StereoSpatialViewer.swift
//  Retroview
//
//  Created by Adam Schuster on 12/1/24.
//

import SwiftUI
import SwiftData

struct StereoSpatialViewer: View {
    let cards: [CardSchemaV1.StereoCard]
    @State private var selectedCard: CardSchemaV1.StereoCard?
    @State private var isViewerVisible = false
    let currentCollection: CollectionSchemaV1.Collection?
    
    var body: some View {
        ZStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 250, maximum: 300))], spacing: 10) {
                    ForEach(cards) { card in
                        ViewerSquareCropView(
                            card: card,
                            currentCollection: currentCollection
                        )
                        .onTapGesture {
                            withAnimation(.spring) {
                                selectedCard = card
                                isViewerVisible = true
                            }
                        }
                    }
                }
                .padding()
            }
            .opacity(isViewerVisible ? 0 : 1)
            
            if let selected = selectedCard {
                StereoBrowser(
                    cards: cards,
                    selectedCard: .init(
                        get: { selected },
                        set: { selectedCard = $0 }
                    ),
                    isVisible: $isViewerVisible,
                    currentCollection: currentCollection
                )
                .opacity(isViewerVisible ? 1 : 0)
            }
        }
    }
}

#Preview {
    CardsPreviewContainer { cards in
        StereoSpatialViewer(
            cards: cards,
            currentCollection: nil
        )
    }
}
