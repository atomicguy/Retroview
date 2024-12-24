//
//  AuthorsView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/22/24.
//

import SwiftData
import SwiftUI

struct AuthorsView: View {
    @Binding var navigationPath: NavigationPath
    @Query(sort: \AuthorSchemaV1.Author.name) private var authors: [AuthorSchemaV1.Author]
    @State private var selection: AuthorSchemaV1.Author?
    
    var body: some View {
        List(authors, selection: $selection) { author in
            NavigationLink(value: author) {
                VStack(alignment: .leading) {
                    Text(author.name)
                        .font(.headline)
                    Text("\(author.cards.count) cards")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Authors")
    }
}
