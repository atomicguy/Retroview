//
//  CollectionViewModel.swift
//  Retroview
//
//  Created by Adam Schuster on 12/9/24.
//

import SwiftUI
import SwiftData

@Observable final class CollectionViewModel {
    var collection: CollectionSchemaV1.Collection
    var selectedCard: CardSchemaV1.StereoCard?
    private let modelContext: ModelContext
    
    init(collection: CollectionSchemaV1.Collection, modelContext: ModelContext) {
        self.collection = collection
        self.modelContext = modelContext
    }
    
    var cards: [CardSchemaV1.StereoCard] {
        collection.fetchCards(context: modelContext)
    }
    
    func addCard(_ card: CardSchemaV1.StereoCard) {
        collection.addCard(card)
        try? modelContext.save()
    }
    
    func removeCard(_ card: CardSchemaV1.StereoCard) {
        collection.removeCard(card)
        try? modelContext.save()
    }
}
