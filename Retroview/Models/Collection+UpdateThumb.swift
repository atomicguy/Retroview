//
//  Collection+UpdateThumb.swift
//  Retroview
//
//  Created by Adam Schuster on 1/12/25.
//

import SwiftData

extension CollectionSchemaV1.Collection {
    @MainActor
    func updateThumbnail(context: ModelContext) async throws {
        let thumbnailData = try await CollectionThumbnailView.generateThumbnail(for: self)
        self.collectionThumbnail = thumbnailData
        try context.save()
    }
}
