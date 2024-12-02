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
    static let libraryName = "Library"

    static let favorites = CollectionSchemaV1.Collection(name: favoritesName)
    static let library = CollectionSchemaV1.Collection(name: libraryName)

    static func setupDefaultCollections(context: ModelContext) {
        let descriptor = FetchDescriptor<CollectionSchemaV1.Collection>()
        let existingCollections = (try? context.fetch(descriptor)) ?? []
        let existingNames = existingCollections.map(\.name)
        
        // Create Favorites if needed
        if !existingNames.contains(favoritesName) {
            context.insert(favorites)
        }

        // Create Library if needed
        if !existingNames.contains(libraryName) {
            context.insert(library)
            
            // Fetch and add all cards
            let cardsDescriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
            if let allCards = try? context.fetch(cardsDescriptor) {
                allCards.forEach { library.addCard($0) }
            }
        }
        
        try? context.save()
    }

    static func isFavorites(_ collection: CollectionSchemaV1.Collection) -> Bool {
        collection.name == favoritesName
    }
    
    static func isLibrary(_ collection: CollectionSchemaV1.Collection) -> Bool {
        collection.name == libraryName
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
