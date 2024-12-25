//
//  CollectionView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/20/24.
//

import OSLog
import SwiftData
import SwiftUI

private let logger = Logger(
    subsystem: "com.example.retroview", category: "CollectionView"
)

struct CollectionView: View {
    @Bindable var collection: CollectionSchemaV1.Collection
    @State private var isProcessing = false
    @State private var selectedCard: CardSchemaV1.StereoCard?
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack {
                CardGridLayout(
                    cards: collection.orderedCards,
                    selectedCard: $selectedCard,
                    onCardSelected: { card in
                        navigationPath.append(card)
                    }
                )
            }
            .navigationTitle("\(collection.name) (\(collection.orderedCards.count) cards)")
            .toolbar {
                Menu {
                    Button(role: .destructive) {
                        Task { @MainActor in
                            guard !isProcessing else { return }
                            isProcessing = true
                            do { isProcessing = false }
                        }
                    } label: {
                        Label("Clear Collection", systemImage: "trash")
                    }
                    .disabled(isProcessing)
                } label: {
                    Label("More", systemImage: "ellipsis.circle")
                        .opacity(isProcessing ? 0.5 : 1.0)
                }
            }
        }
    }
}
