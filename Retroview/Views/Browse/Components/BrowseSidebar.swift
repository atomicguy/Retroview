//
//  BrowseSidebar.swift
//  Retroview
//
//  Created by Adam Schuster on 12/9/24.
//

import SwiftData
import SwiftUI

struct BrowseSidebar: View {
    @Environment(\.modelContext) private var modelContext
    @Binding var selectedDestination: AppDestination?
    @State private var searchText = ""
    @State private var showingImportSheet = false
    
    // Queries for each section
    @Query(sort: \CollectionSchemaV1.Collection.name) private var collections: [CollectionSchemaV1.Collection]
    @Query(sort: \SubjectSchemaV1.Subject.name) private var subjects: [SubjectSchemaV1.Subject]
    @Query(sort: \AuthorSchemaV1.Author.name) private var authors: [AuthorSchemaV1.Author]
    
    var body: some View {
        List(selection: $selectedDestination) {
            Section("Library") {
                NavigationLink(value: AppDestination.library) {
                    Label("All Cards", systemImage: "photo.stack")
                }
            }
            
            Section("Collections") {
                ForEach(collections) { collection in
                    NavigationLink(
                        value: AppDestination.collection(collection.id, collection.name)
                    ) {
                        Label {
                            HStack {
                                Text(collection.name)
                                Spacer()
                                Text("\(collection.cardOrder.count)")
                                    .foregroundStyle(.secondary)
                                    .monospacedDigit()
                            }
                        } icon: {
                            Image(systemName: collection.name == "Favorites" ? "heart.fill" : "folder")
                        }
                    }
                }
            }
            
            Section("Browse") {
                NavigationLink(value: AppDestination.subjects) {
                    Label("Subjects", systemImage: "tag")
                }
                
                NavigationLink(value: AppDestination.authors) {
                    Label("Authors", systemImage: "person")
                }
            }
        }
        .navigationTitle("Retroview")
        .searchable(text: $searchText, prompt: "Search")
        .sheet(isPresented: $showingImportSheet) {
            ImportView(modelContext: modelContext)
        }
        .toolbar {
            ToolbarItem {
                Menu {
                    Button {
                        createNewCollection()
                    } label: {
                        Label("New Collection", systemImage: "folder.badge.plus")
                    }
                    
                    Button {
                        showingImportSheet = true
                    } label: {
                        Label("Import Cards", systemImage: "square.and.arrow.down")
                    }
                    
                    #if DEBUG
                    Divider()
                    
                    Button(role: .destructive) {
                        resetStore()
                    } label: {
                        Label("Reset Store", systemImage: "arrow.counterclockwise")
                    }
                    #endif
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }
    
    private func createNewCollection() {
        let collection = CollectionSchemaV1.Collection(name: "New Collection")
        modelContext.insert(collection)
        try? modelContext.save()
    }
    
    private func resetStore() {
        DevelopmentFlags.shouldResetStore = true
        #if os(macOS)
        NSApplication.shared.terminate(nil)
        #else
        exit(0)
        #endif
    }
}

#Preview {
    NavigationSplitView {
        BrowseSidebar(selectedDestination: .constant(nil))
    } detail: {
        Text("Detail View")
    }
    .withPreviewData()
}
