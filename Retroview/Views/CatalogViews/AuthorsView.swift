//
//  AuthorsView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/22/24.
//

import SwiftUI

struct AuthorsView: View {
    var body: some View {
        CatalogContainerView<AuthorSchemaV1.Author>(
            title: "Authors",
            icon: "person",
            sortDescriptor: SortDescriptor(\AuthorSchemaV1.Author.name)
        )
    }
}
