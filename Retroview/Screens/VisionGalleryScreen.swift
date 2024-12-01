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
    
    enum GalleryTab {
        case library
        case subjects
        case authors
        case collections
        
        var title: String {
            switch self {
            case .library: return "Library"
            case .subjects: return "Subjects"
            case .authors: return "Authors"
            case .collections: return "Collections"
            }
        }
        
        var icon: String {
            switch self {
            case .library: return "photo.on.rectangle.angled"
            case .subjects: return "tag"
            case .authors: return "person"
            case .collections: return "folder"
            }
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            LibraryView()
                .tabItem {
                    Label("Library", systemImage: GalleryTab.library.icon)
                }
                .tag(GalleryTab.library)
            
            SubjectsView()
                .tabItem {
                    Label("Subjects", systemImage: GalleryTab.subjects.icon)
                }
                .tag(GalleryTab.subjects)
            
            AuthorsView()
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
        .platformToolbar {
            EmptyView()
        } trailing: {
            HStack {
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
