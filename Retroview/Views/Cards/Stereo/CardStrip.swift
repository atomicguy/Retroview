//
//  CardStrip.swift
//  Retroview
//
//  Created by Adam Schuster on 12/9/24.
//

#if os(visionOS)
import RealityKit
import StereoViewer

struct CardStrip: View {
    let cards: [CardSchemaV1.StereoCard]
    @Binding var selectedCard: CardSchemaV1.StereoCard
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                ForEach(cards) { card in
                    ThumbnailView(card: card)
                        .frame(width: 120, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(card.id == selectedCard.id ? Color.accentColor : Color.clear,
                                      lineWidth: 2)
                        )
                        .onTapGesture {
                            withAnimation {
                                selectedCard = card
                            }
                        }
                }
            }
            .padding(.horizontal)
        }
        .background(.ultraThinMaterial)
    }
}
#endif
