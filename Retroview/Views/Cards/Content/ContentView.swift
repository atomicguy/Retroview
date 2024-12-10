//
//  ContentView.swift
//  Retroview
//
//  Created by Assistant on 12/9/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedDestination: AppDestination?
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationSplitView {
            BrowseSidebar(selectedDestination: $selectedDestination)
        } detail: {
            NavigationStack {
                switch selectedDestination {
                case .library:
                    LibraryView()
                case .collection(let id, let name):
                    let descriptor = FetchDescriptor<CollectionSchemaV1.Collection>(
                        predicate: #Predicate<CollectionSchemaV1.Collection> { $0.id == id }
                    )
                    
                    FetchedResult(descriptor) { collections in
                        if let collection = collections.first {
                            CollectionView(collection: collection)
                                .navigationTitle(name)
                        }
                    }
                case .subjects:
                    SubjectsView()
                        .navigationTitle("Subjects")
                case .authors:
                    AuthorsView()
                        .navigationTitle("Authors")
                case nil:
                    ContentUnavailableView(
                        "No Selection",
                        systemImage: "photo.stack",
                        description: Text("Select an item from the sidebar")
                    )
                }
            }
        }
    }
}

// Helper view to handle fetching with SwiftData
struct FetchedResult<T: PersistentModel, Content: View>: View {
    @Environment(\.modelContext) private var modelContext
    let descriptor: FetchDescriptor<T>
    let content: ([T]) -> Content
    
    init(_ descriptor: FetchDescriptor<T>, @ViewBuilder content: @escaping ([T]) -> Content) {
        self.descriptor = descriptor
        self.content = content
    }
    
    var body: some View {
        let results = (try? modelContext.fetch(descriptor)) ?? []
        content(results)
    }
}

#Preview {
    ContentView()
        .withPreviewData()
}

enum AppDestination: Hashable {
    case library
    case collection(UUID, String)
    case subjects
    case authors
}
