//
//  CollectionsView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/9/24.
//

import SwiftData
import SwiftUI

struct CollectionsView: View {
    @Query private var collections: [CollectionSchemaV1.Collection]
    @State private var selectedCollection: CollectionSchemaV1.Collection?
    
    var body: some View {
        NavigationSplitView {
            List(collections, selection: $selectedCollection) { collection in
                CollectionListItem(
                    collection: collection,
                    isSelected: selectedCollection?.id == collection.id
                )
            }
        } detail: {
            if let collection = selectedCollection {
                CollectionView(collection: collection)
            } else {
                ContentUnavailableView(
                    "No Collection Selected",
                    systemImage: "folder",
                    description: Text("Select a collection to view its contents")
                )
            }
        }
    }
}
