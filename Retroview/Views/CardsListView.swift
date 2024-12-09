//
//  CardsListView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/8/24.
//

import SwiftData
import SwiftUI

struct CardsListView: View {
    @Query(sort: \StereoCard.primaryTitle) private var cards: [StereoCard]
    @Binding var selectedCard: StereoCard?
    let importer: MODSJSONImporter
    
    var body: some View {
        ZStack {
            List(cards) { card in
                CardRow(card: card)
                    .tag(card)
            }
            
            if importer.isImporting {
                ImportProgressView(
                    progress: importer.importProgress,
                    processed: importer.processedCards,
                    total: importer.totalCards
                )
            }
        }
    }
}
