//
//  SidebarView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/20/24.
//

import SwiftData
import SwiftUI

struct Sidebar: View {
    @Binding var selectedDestination: AppDestination?

    // Separate query for favorites using our existing predicate
    @Query(filter: ModelPredicates.Collection.favorites)
    private var favorites: [CollectionSchemaV1.Collection]

    // Query for non-favorites collections
    @Query(
        filter: #Predicate<CollectionSchemaV1.Collection> {
            $0.name != "Favorites"
        }, sort: \CollectionSchemaV1.Collection.name)
    private var otherCollections: [CollectionSchemaV1.Collection]

    var body: some View {
        List(selection: $selectedDestination) {
            Section {
                NavigationLink(value: AppDestination.library) {
                    Label("Library", systemImage: "photo.on.rectangle.angled")
                        .modifier(SerifFontModifier())
                }

                NavigationLink(value: AppDestination.subjects) {
                    Label("Subjects", systemImage: "tag")
                        .modifier(SerifFontModifier())
                }

                NavigationLink(value: AppDestination.authors) {
                    Label("Authors", systemImage: "person")
                        .modifier(SerifFontModifier())
                }
                
                NavigationLink(value: AppDestination.collections) {
                                    Label("Collections", systemImage: "archivebox")
                                }
            }
            .modifier(SerifFontModifier())

            Section("Collections") {
                // Show Favorites first
                if let favorite = favorites.first {
                    NavigationLink(
                        value: AppDestination.collection(
                            favorite.id, favorite.name)
                    ) {
                        Label(favorite.name, systemImage: "heart.fill")
                            .modifier(SerifFontModifier())
                    }
                }

                // Show other collections
                ForEach(otherCollections) { collection in
                    NavigationLink(
                        value: AppDestination.collection(
                            collection.id, collection.name)
                    ) {
                        Label(collection.name, systemImage: "folder")
                            .modifier(SerifFontModifier())
                    }
                }
            }
            .modifier(SerifFontModifier())
        }
        .modifier(SerifFontModifier())
    }
}

#Preview("Sidebar View") {
    Sidebar(selectedDestination: .constant(.library))
        .withPreviewStore()
}
