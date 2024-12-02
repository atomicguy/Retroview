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
        @Environment(\.modelContext) private var modelContext
        @State private var selectedCollection: CollectionSchemaV1.Collection?

        private let columns = [
            GridItem(.adaptive(minimum: 300, maximum: 350), spacing: 20),
        ]

        var body: some View {
            NavigationStack {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 20) {
                        ForEach(collections) { collection in
                            NavigationLink(value: collection) {
                                CollectionThumbnailView(collection: collection)
                            }
                        }
                    }
                    .padding()
                }
                .navigationDestination(for: CollectionSchemaV1.Collection.self) { collection in
                    let cards = collection.fetchCards(context: modelContext)
                    StereoSpatialViewer(
                        cards: cards,
                        currentCollection: collection
                    )
                }
            }
        }
    }

    #Preview {
        VisionCollectionsView()
            .withPreviewContainer()
    }
#endif
