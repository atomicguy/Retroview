//
//  VisionCollectionsView.swift
//  Retroview
//
//  Created by Adam Schuster on 11/30/24.
//

import SwiftUI
import SwiftData

#if os(visionOS)
struct VisionCollectionsView: View {
    @Query(sort: \CollectionSchemaV1.Collection.name) private var collections: [CollectionSchemaV1.Collection]
    @State private var selectedCollection: CollectionSchemaV1.Collection?
    @Environment(\.modelContext) private var modelContext
    
    private let columns = [
        GridItem(.adaptive(minimum: 300, maximum: 350), spacing: 20)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(collections) { collection in
                    CollectionThumbnailView(collection: collection)
                        .onTapGesture {
                            selectedCollection = collection
                        }
                }
            }
            .padding()
        }
        .sheet(item: $selectedCollection) { collection in
            CollectionStereoView(collection: collection)
        }
    }
}

private struct CollectionStereoView: View {
    @Environment(\.presentationMode) private var presentationMode
    let collection: CollectionSchemaV1.Collection
    @Environment(\.modelContext) private var modelContext
    @State private var selectedCard: CardSchemaV1.StereoCard?
    
    private var cards: [CardSchemaV1.StereoCard] {
        collection.fetchCards(context: modelContext)
    }
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            VStack {
                if let selectedCard {
                    StereoView(card: selectedCard)
                        .id(selectedCard.uuid)
                        .toolbar(.hidden)
                } else {
                    ContentUnavailableView(
                        "No Card Selected",
                        systemImage: "photo.on.rectangle",
                        description: Text("Select a card from the ornament below")
                    )
                }
            }
            
            Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .font(.title)
                    .foregroundColor(.primary)
                    .padding(16)
            }
            .background(Color(uiColor: .systemBackground))
            .cornerRadius(8)
            .padding(16)
        }
        .ornament(visibility: .visible, attachmentAnchor: .scene(.bottom)) {
            StereoCardThumbnailOrnament(cards: cards) { card in
                selectedCard = card
            }
        }
    }
}

#Preview {
    VisionCollectionsView()
        .withPreviewContainer()
}
#endif
