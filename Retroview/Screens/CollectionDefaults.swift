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

    static let favorites = CollectionSchemaV1.Collection(
        name: favoritesName,
        cards: []
    )

    static func setupDefaultCollections(context: ModelContext) {
        // Check if Favorites collection already exists
        let descriptor = FetchDescriptor<CollectionSchemaV1.Collection>(
            predicate: #Predicate<CollectionSchemaV1.Collection> { collection in
                collection.name == favoritesName
            }
        )

        guard (try? context.fetch(descriptor))?.isEmpty ?? true else {
            return // Favorites already exists
        }

        // Create Favorites collection
        context.insert(favorites)
        try? context.save()
    }

    static func isFavorites(_ collection: CollectionSchemaV1.Collection) -> Bool {
        collection.name == favoritesName
    }
}

extension CollectionDefaults {
    static func favoritesDescriptor() -> FetchDescriptor<
        CollectionSchemaV1.Collection
    > {
        FetchDescriptor<CollectionSchemaV1.Collection>(
            predicate: #Predicate<CollectionSchemaV1.Collection> { collection in
                collection.name == favoritesName
            }
        )
    }
}
