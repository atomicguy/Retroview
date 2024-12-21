//
//  SidebarView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/20/24.
//

import SwiftUI
import SwiftData

struct Sidebar: View {
    @Binding var selectedDestination: AppDestination?
    @Query(sort: \CollectionSchemaV1.Collection.name) private var collections: [CollectionSchemaV1.Collection]
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        List(selection: $selectedDestination) {
            Section {
                NavigationLink(value: AppDestination.library) {
                    Label("Library", systemImage: "photo.on.rectangle.angled")
                }
                
                NavigationLink(value: AppDestination.subjects) {
                    Label("Subjects", systemImage: "tag")
                }
                
                NavigationLink(value: AppDestination.authors) {
                    Label("Authors", systemImage: "person")
                }
            }
            
            Section("Collections") {
                ForEach(collections) { collection in
                    NavigationLink(
                        value: AppDestination.collection(collection.id, collection.name)
                    ) {
                        Label(collection.name,
                              systemImage: CollectionDefaults.isFavorites(collection) ? "heart.fill" : "folder")
                    }
                }
            }
        }
        .navigationTitle("Retroview")
    }
}
