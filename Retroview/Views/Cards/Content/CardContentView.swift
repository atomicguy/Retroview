//
//  CardContentView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/9/24.
//

import SwiftData
import SwiftUI

struct CardContentView: View {
    let card: CardSchemaV1.StereoCard
    @State private var viewModel: CardViewModel
    
    init(card: CardSchemaV1.StereoCard) {
        self.card = card
        _viewModel = State(initialValue: CardViewModel(card: card))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(card.titlePick?.text ?? card.titles.first?.text ?? "Untitled")
                    .font(.title)
                    .frame(maxWidth: .infinity)
                
                CardImageView(card: card, side: .front)
                
                OrnamentalDivider()
                
                CardMetadataView(card: card)
                
                OrnamentalDivider()
                
                Text("Reverse")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                
                CardImageView(card: card, side: .back)
            }
            .padding()
        }
    }
}
