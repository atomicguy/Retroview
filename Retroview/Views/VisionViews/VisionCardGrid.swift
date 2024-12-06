//
//  VisionCardGrid.swift
//  Retroview
//
//  Created by Adam Schuster on 12/4/24.
//

import SwiftUI

struct VisionCardGrid: View {
    let cards: [CardSchemaV1.StereoCard]
    @State private var selectedCard: CardSchemaV1.StereoCard?
    @State private var showingStereoBrowser = false
    
    private let columns = [
        GridItem(.adaptive(minimum: 250, maximum: 300), spacing: 10),
    ]
    
    var body: some View {
        ZStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(cards) { card in
                        CardSquareView(card: card)
                            .withTitle()
                            .onTapGesture {
                                selectedCard = card
                                withAnimation(.spring) {
                                    showingStereoBrowser = true
                                }
                            }
                    }
                }
                .padding()
            }
            .opacity(showingStereoBrowser ? 0 : 1)
            
            if showingStereoBrowser, let selected = selectedCard {
                StereoBrowser(
                    cards: cards,
                    selectedCard: .init(
                        get: { selected },
                        set: { selectedCard = $0 }
                    ),
                    isVisible: $showingStereoBrowser,
                    currentCollection: nil
                )
                .opacity(showingStereoBrowser ? 1 : 0)
            }
        }
    }
}
