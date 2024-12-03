//
//  CollectionPreview.swift
//  Retroview
//
//  Created by Adam Schuster on 12/2/24.
//

import SwiftData
import SwiftUI

struct CollectionPreview<T: CardCollection>: View {
    let collection: T

    var body: some View {
        VStack(spacing: 0) {
            // Preview of first 4 cards
            HStack(spacing: 4) {
                ForEach(collection.cards.prefix(4)) { card in
                    ThumbnailView(card: card)
                        .frame(height: 60)
                }

                ForEach(0 ..< max(0, 4 - collection.cards.count), id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.secondary.opacity(0.2))
                        .frame(height: 60)
                }
            }
            .padding(8)

            // Collection name
            ZStack {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .aspectRatio(16 / 10, contentMode: .fit)

                Text(collection.name)
                    .font(.system(.headline, design: .serif))
                    .foregroundStyle(.primary)
            }
        }
        .background(.ultraThickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 5)
    }
}

#Preview("Collection Preview - With Cards") {
    CollectionPreview(collection: PreviewContainer.shared.worldsFairCollection)
        .frame(width: 300, height: 200)
        .padding()
        .withPreviewContainer()
}

#Preview("Collection Preview - Empty") {
    CollectionPreview(
        collection: CollectionSchemaV1.Collection(name: "Empty Collection")
    )
    .frame(width: 300, height: 200)
    .padding()
    .withPreviewContainer()
}

#Preview("Collection Preview - Grid Layout") {
    ScrollView {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))], spacing: 20) {
            ForEach(0 ..< 4) { _ in
                CollectionPreview(collection: PreviewContainer.shared.worldsFairCollection)
            }
        }
        .padding()
    }
    .withPreviewContainer()
}

// Optional: Preview showing different collection types
#Preview("Collection Preview - Various Collections") {
    ScrollView {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))], spacing: 20) {
            CollectionPreview(collection: PreviewContainer.shared.worldsFairCollection)
            CollectionPreview(collection: PreviewContainer.shared.naturalWondersCollection)
            CollectionPreview(collection: PreviewContainer.shared.newYorkCollection)
        }
        .padding()
    }
    .withPreviewContainer()
}
