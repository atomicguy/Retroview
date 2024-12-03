//
//  BrowseView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/2/24.
//

import SwiftUI

struct BrowseView<T: CardCollection>: View {
    @StateObject var viewModel: BrowseViewModel<T>
    let title: String

    var body: some View {
        #if os(visionOS)
            visionLayout
        #else
            desktopLayout
        #endif
    }

    // MARK: - Platform-specific layouts

    private var visionLayout: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))], spacing: 20) {
                    ForEach(viewModel.collections) { collection in
                        NavigationLink(value: collection) {
                            CollectionPreview(collection: collection)
                        }
                    }
                }
                .padding()
            }
            .navigationDestination(for: T.self) { collection in
                CardCollectionGrid(
                    cards: collection.cards,
                    selectedCard: $viewModel.selectedCard
                )
                .navigationTitle(collection.name)
            }
            .navigationTitle(title)
        }
    }

    private var desktopLayout: some View {
        HStack(spacing: 0) {
            // Collections List
            List(viewModel.collections, selection: $viewModel.selectedCollection) { collection in
                CollectionRow(collection: collection)
            }
            .frame(width: 220)

            Divider()

            // Cards Grid
            if let selectedCollection = viewModel.selectedCollection {
                CardCollectionGrid(
                    cards: selectedCollection.cards,
                    selectedCard: $viewModel.selectedCard
                )
                .frame(maxWidth: .infinity)
            } else {
                ContentUnavailableView(
                    "No Collection Selected",
                    systemImage: "photo.on.rectangle",
                    description: Text("Select a collection to view its cards")
                )
                .frame(maxWidth: .infinity)
            }

            Divider()

            // Card Details
            Group {
                if let selectedCard = viewModel.selectedCard {
                    CardContentView(card: selectedCard)
                        .id(selectedCard.uuid)
                        .transition(.move(edge: .trailing))
                } else {
                    ContentUnavailableView(
                        "No Card Selected",
                        systemImage: "photo.on.rectangle",
                        description: Text("Select a card to view its details")
                    )
                    .transition(.opacity)
                }
            }
            .frame(width: 300)
            .animation(.smooth, value: viewModel.selectedCard)
        }
    }
}

#Preview("Browse View - Desktop") {
    BrowseView(
        viewModel: BrowseViewModel(
            collections: [
                SubjectSchemaV1.Subject(name: "Sample Subject"),
                SubjectSchemaV1.Subject(name: "Another Subject"),
            ]
        ),
        title: "Browse Subjects"
    )
    .withPreviewContainer()
    .frame(width: 1200, height: 800)
}

#Preview("Browse View - Vision") {
    BrowseView(
        viewModel: BrowseViewModel(
            collections: [
                PreviewContainer.shared.worldsFairCollection,
                PreviewContainer.shared.naturalWondersCollection,
            ]
        ),
        title: "Browse Subjects"
    )
    .withPreviewContainer()
}
