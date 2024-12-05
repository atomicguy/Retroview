//
//  ExampleViews.swift
//  Retroview
//
//  Created by Adam Schuster on 12/2/24.
//

import SwiftData
import SwiftUI

struct SubjectsView: View {
    @Query(sort: \SubjectSchemaV1.Subject.name) private var subjects: [SubjectSchemaV1.Subject]

    var body: some View {
        BrowseView(
            viewModel: BrowseViewModel(collections: subjects),
            title: "Subjects"
        )
    }
}

struct AuthorsView: View {
    @Query(sort: \AuthorSchemaV1.Author.name) private var authors: [AuthorSchemaV1.Author]

    var body: some View {
        BrowseView(
            viewModel: BrowseViewModel(collections: authors),
            title: "Authors"
        )
    }
}

struct CollectionsView: View {
    @Query(sort: \CollectionSchemaV1.Collection.name) private var collections: [CollectionSchemaV1.Collection]

    var body: some View {
        BrowseView(
            viewModel: BrowseViewModel(collections: collections),
            title: "Collections"
        )
    }
}

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
