//
//  BrowseViewModel.swift
//  Retroview
//
//  Created by Adam Schuster on 12/2/24.
//

import SwiftUI

@MainActor
class BrowseViewModel<T: CardCollection>: ObservableObject {
    @Published var collections: [T]
    @Published var selectedCollection: T?
    @Published var selectedCard: CardSchemaV1.StereoCard?

    init(collections: [T]) {
        self.collections = collections
    }
}
