//
//  StereoSpatialViewer.swift
//  Retroview
//
//  Created by Adam Schuster on 12/1/24.
//

import SwiftData
import SwiftUI

#if os(visionOS)
    struct StereoSpatialViewer: View {
        let cards: [CardSchemaV1.StereoCard]
        let currentCollection: CollectionSchemaV1.Collection?
        @State private var selectedCard: CardSchemaV1.StereoCard?
        @State private var isViewerVisible = false
        @State private var isGridVisible = true

        var body: some View {
            ZStack {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 250, maximum: 300))], spacing: 10) {
                        ForEach(cards) { card in
                            CardSquareView(card: card)
                                .withTitle()
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                        selectedCard = card
                                        isViewerVisible = true
                                        isGridVisible = false
                                    }
                                }
                        }
                    }
                    .padding()
                }
                .opacity(isGridVisible ? 1 : 0)
                .animation(.easeInOut(duration: 0.3), value: isGridVisible)

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
                    .onChange(of: isViewerVisible) { _, newValue in
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isGridVisible = !newValue
                        }
                    }
                }
            }
            .animation(.easeInOut, value: selectedCard)
        }
    }

//    #Preview {
//        CardsPreviewContainer { cards in
//            StereoSpatialViewer(
//                cards: cards,
//                currentCollection: nil
//            )
//        }
//    }
#endif
