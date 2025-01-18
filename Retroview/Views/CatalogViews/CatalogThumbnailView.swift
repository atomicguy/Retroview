//
//  CatalogThumbnailView.swift
//  Retroview
//
//  Created by Adam Schuster on 1/12/25.
//

import SwiftUI

struct CatalogThumbnailView<T: CatalogItem>: View {
    let item: T
    let maxStackedCards = 5

    var body: some View {
        let previewCollection = CollectionSchemaV1.Collection(name: item.name)

        CollectionThumbnailView(
            collection: previewCollection,
            cards: Array(item.cards.prefix(maxStackedCards))
        )
        .task {
            await generateThumbnail()
        }
    }

    @MainActor
    private func generateThumbnail() async {
        guard item.thumbnailData == nil else { return }

        let renderer = ImageRenderer(content: self)

        #if os(macOS)
            guard let nsImage = renderer.nsImage,
                let tiffData = nsImage.tiffRepresentation(
                    using: .jpeg, factor: 0.8)
            else { return }
            item.thumbnailData = tiffData
        #else
            guard let uiImage = renderer.uiImage,
                let thumbnailData = uiImage.jpegData(compressionQuality: 0.8)
            else { return }
            item.thumbnailData = thumbnailData
        #endif
    }
}
