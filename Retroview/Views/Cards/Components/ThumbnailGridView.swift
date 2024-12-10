//
//  ThumbnailGridView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/3/24.
//

import SwiftUI
import SwiftData

struct ThumbnailGrid: View {
    let cards: [CardSchemaV1.StereoCard]
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(cards.prefix(6)) { card in
                ThumbnailView(card: card)
                    .aspectRatio(2/1, contentMode: .fill)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            
            if cards.count < 6 {
                ForEach(0..<(6 - cards.count), id: \.self) { _ in
                    Rectangle()
                        .fill(.secondary.opacity(0.2))
                        .aspectRatio(2/1, contentMode: .fill)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }
        }
    }
}

#Preview("ThumbnailGrid - Full") {
    let descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
    let container = try! PreviewDataManager.shared.container
    let cards = try! container?.mainContext.fetch(descriptor)
    
    ThumbnailGrid(cards: cards!)
        .padding()
        .frame(width: 300)
        .background(.ultraThinMaterial)
        .withPreviewData()
}
