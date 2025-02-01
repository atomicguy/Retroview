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
                }
            }
            .padding(PlatformEnvironment.Metrics.defaultPadding)
        }
        .platformNavigationTitle("Collections")
    }
}

#Preview {
    NavigationStack {
        CollectionsGridView(navigationPath: .constant(NavigationPath()))
            .withPreviewStore()
            .frame(width: 600, height: 300)
    }
}
