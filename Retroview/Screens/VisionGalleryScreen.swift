//
//  VisionGalleryScreen.swift
//  Retroview
//
//  Created by Adam Schuster on 11/30/24.
//

import SwiftData
import SwiftUI

#if os(visionOS)
struct VisionGalleryScreen: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab: GalleryTab = .library
    @State private var showingImport = false
    
    // Query all cards at this level to make them available to the container
    @Query private var allCards: [CardSchemaV1.StereoCard]
    
    enum GalleryTab: String {
        case library
        case subjects
        case authors
        case collections
        
        var title: String {
            switch self {
            case .library: "Library"
            case .subjects: "Subjects"
            case .authors: "Authors"
            case .collections: "Collections"
            }
        }
        
        var icon: String {
            switch self {
            case .library: "photo.on.rectangle.angled"
            case .subjects: "tag"
            case .authors: "person"
            case .collections: "folder"
            }
        }
    }
    
    var body: some View {
        SpatialBrowserContainer(cards: allCards) {
            NavigationStack {
                TabView(selection: $selectedTab) {
                    LibraryView()
                        .tabItem {
                            Label("Library", systemImage: GalleryTab.library.icon)
                        }
                        .tag(GalleryTab.library)
                    
                    VisionSubjectsView()
                        .tabItem {
                            Label("Subjects", systemImage: GalleryTab.subjects.icon)
                        }
                        .tag(GalleryTab.subjects)
                    
                    VisionAuthorsView()
                        .tabItem {
                            Label("Authors", systemImage: GalleryTab.authors.icon)
                        }
                        .tag(GalleryTab.authors)
                    
                    VisionCollectionsView()
                        .tabItem {
                            Label("Collections", systemImage: GalleryTab.collections.icon)
                        }
                        .tag(GalleryTab.collections)
                }
                .navigationTitle(selectedTab.title)
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        toolbarButton(
                            title: "Import Cards",
                            systemImage: "square.and.arrow.down"
                        ) {
                            showingImport = true
                        }
                        
                        #if DEBUG
                        DebugMenu()
                        #endif
                    }
                }
            }
        }
        .sheet(isPresented: $showingImport) {
            ImportView(modelContext: modelContext)
        }
    }
}

#Preview {
    VisionGalleryScreen()
        .withPreviewContainer()
}
#endif
