//
//  BrowseViewModel.swift
//  Retroview
//
//  Created by Adam Schuster on 12/2/24.
//

import SwiftUI

@MainActor
class BrowseViewModel<T: CardGrouping>: ObservableObject {
    @Published var collections: [T]
    @Published var selectedCollection: T?
    @Published var selectedCard: CardSchemaV1.StereoCard?
    @Published var isNavigating = false
    @Published private(set) var navigatingToCollection: T?
    
    init(collections: [T]) {
        self.collections = collections
    }
    
    func navigate(to collection: T) {
        navigatingToCollection = collection
        isNavigating = true
    }
}
