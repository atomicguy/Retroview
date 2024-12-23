//
//  CardHeaderView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/22/24.
//

import SwiftUI

struct CardHeaderView: View {
    let card: CardSchemaV1.StereoCard
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text(card.titlePick?.text ?? "Untitled")
                    .font(.system(.title, design: .serif))

                if !card.authors.isEmpty {
                    Text(card.authors.map(\.name).joined(separator: ", "))
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            FavoriteButton(card: card)
                .labelStyle(.iconOnly)
                .font(.title2)
        }
    }
}
