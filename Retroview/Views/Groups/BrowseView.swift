//
//  BrowseView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/2/24.
//

import SwiftData
import SwiftUI

struct BrowseView<T: CardGrouping>: View {
    @StateObject private var viewModel: BrowseViewModel<T>
    let title: String
    
    init(collections: [T], title: String) {
        _viewModel = StateObject(wrappedValue: BrowseViewModel(collections: collections))
        self.title = title
    }
    
    var body: some View {
        #if os(visionOS)
        visionOSLayout
        #else
        defaultLayout
        #endif
    }
    
    // MARK: - Platform Specific Layouts
    
    private var visionOSLayout: some View {
        NavigationStack {
            CollectionsGrid(
                collections: viewModel.collections,
                selectedCollection: $viewModel.selectedCollection
            )
            .navigationDestination(isPresented: $viewModel.isNavigating) {
                if let collection = viewModel.navigatingToCollection {
                    CardGroupingGrid(
                        cards: collection.cards,
                        selectedCard: $viewModel.selectedCard,
                        currentCollection: nil
                    )
                    .navigationTitle(collection.name)
                }
            }
            .navigationTitle(title)
        }
    }
    
    private var defaultLayout: some View {
        HStack(spacing: 0) {
            // Collections List
            CollectionsList(
                collections: viewModel.collections,
                selectedCollection: $viewModel.selectedCollection
            )
            .frame(width: 280)
            
            Divider()
            
            // Cards Grid
            if let selectedCollection = viewModel.selectedCollection {
                CardGroupingGrid(
                    cards: selectedCollection.cards,
                    selectedCard: $viewModel.selectedCard,
                    currentCollection: nil
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
            CardDetailsPanel(selectedCard: viewModel.selectedCard)
                .frame(width: 300)
        }
    }
}

// MARK: - Supporting Views

private struct CollectionsGrid<T: CardGrouping>: View {
    let collections: [T]
    @Binding var selectedCollection: T?
    
    private let columns = [
        GridItem(.adaptive(minimum: 300, maximum: 350), spacing: 20)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(collections) { collection in
                    GroupingPreview(collection: collection, isSelected: selectedCollection?.id == collection.id)
                        #if os(visionOS)
                        .hoverHighlight()
                        #endif
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedCollection = collection
                        }
                }
            }
            .padding()
        }
    }
}

private struct CollectionsList<T: CardGrouping>: View {
    let collections: [T]
    @Binding var selectedCollection: T?
    
    var body: some View {
        List(collections, selection: $selectedCollection) { collection in
            GroupingRow(collection: collection)
                .tag(collection)
        }
    }
}

private struct CardDetailsPanel: View {
    let selectedCard: CardSchemaV1.StereoCard?
    
    var body: some View {
        Group {
            if let card = selectedCard {
                CardContentView(card: card)
                    .id(card.uuid)
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
        .animation(.smooth, value: selectedCard)
    }
}

// MARK: - Preview Support

#Preview("Browse View - Desktop") {
    let container = try! PreviewDataManager.shared.container()
    let collectionDescriptor = FetchDescriptor<CollectionSchemaV1.Collection>()
    let collections = try! container.mainContext.fetch(collectionDescriptor)
    
    return BrowseView(
        collections: collections,
        title: "Browse Collections"
    )
    .withPreviewData()
    .frame(width: 1200, height: 800)
}

//#Preview("Browse View - Vision") {
//    BrowseView(
//        collections: [
//            PreviewContainer.shared.worldsFairCollection,
//            PreviewContainer.shared.naturalWondersCollection,
//        ],
//        title: "Browse Collections"
//    )
//    .withPreviewData()
//}
