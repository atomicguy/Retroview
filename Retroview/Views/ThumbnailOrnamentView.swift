//
//  ThumbnailOrnamentView.swift
//  Retroview
//
//  Created by Adam Schuster on 11/30/24.
//

import SwiftUI
import SwiftData

struct StereoCardThumbnailOrnament: View {
    let cards: [CardSchemaV1.StereoCard]
    let onSelect: (CardSchemaV1.StereoCard) -> Void
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: [GridItem(.flexible())], spacing: 8) {
                ForEach(cards) { card in
                    ThumbnailView(card: card)
                        .frame(width: 80, height: 80)
                        .onTapGesture {
                            onSelect(card)
                        }
                }
            }
            .padding(.horizontal, 8)
        }
        .frame(height: 96)
    }
}

private struct ThumbnailView: View {
    let card: CardSchemaV1.StereoCard
    @StateObject private var viewModel: StereoCardViewModel
    
    init(card: CardSchemaV1.StereoCard) {
        self.card = card
        _viewModel = StateObject(wrappedValue: StereoCardViewModel(stereoCard: card))
    }
    
    var body: some View {
        ZStack {
            if let image = viewModel.frontCGImage {
                Image(decorative: image, scale: 1.0)
                    .resizable()
                    .scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                ProgressView()
            }
        }
        .task {
            try? await viewModel.loadImage(forSide: "front")
        }
    }
}

#Preview("Thumbnail Ornament") {
    CardsPreviewContainer { cards in
        StereoCardThumbnailOrnament(cards: cards) { _ in }
            .background(.regularMaterial)
    }
}
