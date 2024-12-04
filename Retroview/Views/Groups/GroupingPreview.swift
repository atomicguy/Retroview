//
//  CollectionPreview.swift
//  Retroview
//
//  Created by Adam Schuster on 12/2/24.
//

import SwiftData
import SwiftUI

struct GroupingPreview<T: CardGrouping>: View {
    let collection: T
    
    var body: some View {
        VStack(spacing: 0) {
            // Top padding
            Spacer(minLength: 16)
            
            // Thumbnails grid
            ThumbnailGrid(cards: Array(collection.cards))
                .padding(.horizontal, 12)
            
            Spacer(minLength: 16)
            
            // Title overlay
            Text(collection.name)
                .font(.system(.subheadline, design: .serif))
                .lineLimit(2)
                .truncationMode(.tail)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(.ultraThickMaterial)
        }
        .aspectRatio(1, contentMode: .fit)
        .frame(height: 280)
        .background(
            LinearGradient(
                colors: [.secondary.opacity(0.1), .secondary.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 5)
    }
}
#Preview("Collection Preview - With Cards") {
    GroupingPreview(collection: PreviewContainer.shared.worldsFairCollection)
        .frame(width: 300, height: 200)
        .padding()
        .withPreviewContainer()
}

#Preview("Collection Preview - Empty") {
    GroupingPreview(
        collection: CollectionSchemaV1.Collection(name: "Empty Collection")
    )
    .frame(width: 300, height: 200)
    .padding()
    .withPreviewContainer()
}

#Preview("Collection Preview - Grid Layout") {
    ScrollView {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))], spacing: 20) {
            ForEach(0..<4) { _ in
                GroupingPreview(
                    collection: PreviewContainer.shared.worldsFairCollection)
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
            GroupingPreview(
                collection: PreviewContainer.shared.worldsFairCollection)
            GroupingPreview(
                collection: PreviewContainer.shared.naturalWondersCollection)
            GroupingPreview(
                collection: PreviewContainer.shared.newYorkCollection)
        }
        .padding()
    }
    .withPreviewContainer()
}
