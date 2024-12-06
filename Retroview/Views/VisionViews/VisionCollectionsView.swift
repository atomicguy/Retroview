//
//  VisionCollectionsView.swift
//  Retroview
//
//  Created by Adam Schuster on 11/30/24.
//

import SwiftData
import SwiftUI

#if os(visionOS)
struct VisionCollectionsView: View {
    @Query(sort: \CollectionSchemaV1.Collection.name) private var collections: [CollectionSchemaV1.Collection]
    @Environment(\.spatialBrowserState) private var browserState
    @State private var selectedCollection: CollectionSchemaV1.Collection?
    @Environment(\.modelContext) private var modelContext
    
    private var columns = [
        GridItem(.adaptive(minimum: 300, maximum: 350), spacing: 10)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(collections) { collection in
                    GroupingPreview(collection: collection, isSelected: selectedCollection?.id == collection.id)
                        .hoverHighlight()
                        .contentShape(Rectangle())
                        .onTapGesture {
                            let cards = collection.fetchCards(context: modelContext)
                            if let firstCard = cards.first {
                                selectedCollection = collection
                                browserState.showBrowser(with: firstCard, cards: cards)
                            }
                        }
                }
            }
            .padding()
        }
        .onChange(of: browserState.selectedCard.wrappedValue) { _, card in
            if card == nil {
                selectedCollection = nil
            }
        }
        .navigationTitle("Collections")
    }
}

#Preview {
    VisionCollectionsView()
        .withPreviewContainer()
}
#endif
