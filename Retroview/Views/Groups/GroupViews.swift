//
//  ExampleViews.swift
//  Retroview
//
//  Created by Adam Schuster on 12/2/24.
//

import SwiftData
import SwiftUI

// MARK: - Subject Views

struct SubjectsView: View {
    @Query(sort: \SubjectSchemaV1.Subject.name) private var subjects: [SubjectSchemaV1.Subject]

    var body: some View {
        BrowseView(
            collections: subjects.filter { !$0.cards.isEmpty },
            title: "Subjects"
        )
    }
}

#if os(visionOS)
struct VisionSubjectsView: View {
    @Query(sort: \SubjectSchemaV1.Subject.name) private var subjects: [SubjectSchemaV1.Subject]
    @Environment(\.spatialBrowserState) private var browserState
    
    var body: some View {
        BrowseView(
            collections: subjects.filter { !$0.cards.isEmpty },
            title: "Subjects"
        )
    }
}
#endif

// MARK: - Author Views

struct AuthorsView: View {
    @Query(sort: \AuthorSchemaV1.Author.name) private var authors: [AuthorSchemaV1.Author]

    var body: some View {
        BrowseView(
            collections: authors.filter { !$0.cards.isEmpty },
            title: "Authors"
        )
    }
}

#if os(visionOS)
struct VisionAuthorsView: View {
    @Query(sort: \AuthorSchemaV1.Author.name) private var authors: [AuthorSchemaV1.Author]
    @Environment(\.spatialBrowserState) private var browserState

    var body: some View {
        BrowseView(
            collections: authors.filter { !$0.cards.isEmpty },
            title: "Authors"
        )
    }
}
#endif

// MARK: - Collection Views

struct CollectionsView: View {
    @Query(sort: \CollectionSchemaV1.Collection.name) private var collections: [CollectionSchemaV1.Collection]
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        BrowseView(
            collections: collections.filter { !$0.cardUUIDs.isEmpty },
            title: "Collections"
        )
        .onAppear {
            // Ensure default collections exist
            CollectionDefaults.setupDefaultCollections(context: modelContext)
        }
    }
}

#if os(visionOS)
struct VisionCollectionsView: View {
    @Query(sort: \CollectionSchemaV1.Collection.name) private var collections: [CollectionSchemaV1.Collection]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.spatialBrowserState) private var browserState

    var body: some View {
        BrowseView(
            collections: collections.filter { !$0.cardUUIDs.isEmpty },
            title: "Collections"
        )
        .onAppear {
            CollectionDefaults.setupDefaultCollections(context: modelContext)
        }
    }
}
#endif

// MARK: - Preview Provider

#Preview("Subjects View") {
    SubjectsView()
        .withPreviewContainer()
        .frame(width: 1200, height: 800)
}

#Preview("Authors View") {
    AuthorsView()
        .withPreviewContainer()
        .frame(width: 1200, height: 800)
}

#Preview("Collections View") {
    CollectionsView()
        .withPreviewContainer()
        .frame(width: 1200, height: 800)
}

#if os(visionOS)
#Preview("Vision Subjects View") {
    VisionSubjectsView()
        .withPreviewContainer()
}

#Preview("Vision Authors View") {
    VisionAuthorsView()
        .withPreviewContainer()
}

#Preview("Vision Collections View") {
    VisionCollectionsView()
        .withPreviewContainer()
}
#endif
