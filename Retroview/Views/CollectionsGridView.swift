//
//  CollectionsGridView.swift
//  Retroview
//
//  Created by Adam Schuster on 1/5/25.
//

import SwiftData
import SwiftUI

struct CollectionsGridView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(
        filter: #Predicate<CollectionSchemaV1.Collection> { collection in
            collection.name != ""
        },
        sort: \.name
    ) private var collections: [CollectionSchemaV1.Collection]
    @Binding var navigationPath: NavigationPath
    
    private var columns: [GridItem] {
        [GridItem(.adaptive(minimum: 250, maximum: 300), spacing: 20)]
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(collections) { collection in
                    StackThumbnailView(item: collection)
                        .platformInteraction(
                            InteractionConfig(
                                onDoubleTap: {
                                    navigationPath.append(collection)
                                }
                            )
                        )
                        .frame(minHeight: 300) 
                        .withCollectionContextMenu(collection)
                        .withAutoThumbnailUpdate(collection)

//                        .task {
//                            if collection.collectionThumbnail == nil {
//                                await cacheCollectionThumbnail(collection)
//                            }
//                        }
                }
            }
            .padding(PlatformEnvironment.Metrics.defaultPadding)
        }
        .platformNavigationTitle("Collections")
    }
    
//    private func cacheCollectionThumbnail(_ collection: CollectionSchemaV1.Collection) async {
//        // Create a renderer to capture the thumbnail view
//        let renderer = ImageRenderer(
//            content: CollectionThumbnailView(collection: collection)
//                .frame(width: 300, height: 300)
//        )
//        
//        // Configure renderer
//        renderer.scale = 2.0
//        
//        // Generate image and convert to Data
//        if let image = renderer.uiImage {
//            if let thumbnailData = image.jpegData(compressionQuality: 0.8) {
//                await MainActor.run {
//                    collection.collectionThumbnail = thumbnailData
//                    try? modelContext.save()
//                }
//            }
//        }
//    }
}

#Preview {
    NavigationStack {
        CollectionsGridView(navigationPath: .constant(NavigationPath()))
            .withPreviewStore()
            .frame(width: 600, height: 300)
    }
}
