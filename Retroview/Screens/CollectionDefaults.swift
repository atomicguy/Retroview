//
//  CollectionDefaults.swift
//  Retroview
//
//  Created by Adam Schuster on 11/28/24.
//

import Foundation
import SwiftData

enum CollectionDefaults {
    static let favoritesName = "Favorites"

    static func setupDefaultCollections(context: ModelContext) {
        let descriptor = FetchDescriptor<CollectionSchemaV1.Collection>()
        let existingCollections = (try? context.fetch(descriptor)) ?? []
        let existingNames = existingCollections.map(\.name)

        // Create Favorites if needed
        if !existingNames.contains(favoritesName) {
            let favorites = CollectionSchemaV1.Collection(name: favoritesName)
            context.insert(favorites)
            try? context.save()
        }
    }

    static func isFavorites(_ collection: CollectionSchemaV1.Collection) -> Bool
    {
        collection.name == favoritesName
    }
}
