//
//  CollectionGridItem.swift
//  Retroview
//
//  Created by Adam Schuster on 12/9/24.
//

import SwiftUI
import SwiftData

struct CollectionGridItem: View {
    @Environment(\.modelContext) private var modelContext
    let collection: CollectionSchemaV1.Collection
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            ThumbnailGrid(cards: collection.fetchCards(context: modelContext))
                .padding(12)
            
            Text(collection.name)
                .font(.headline)
                .lineLimit(1)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
        }
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
        )
    }
}
