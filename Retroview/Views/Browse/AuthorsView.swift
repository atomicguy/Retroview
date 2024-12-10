//
//  AuthorsView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/9/24.
//

import SwiftData
import SwiftUI

struct AuthorsView: View {
    @Query private var authors: [AuthorSchemaV1.Author]
    @State private var selectedAuthor: AuthorSchemaV1.Author?
    @State private var selectedCard: CardSchemaV1.StereoCard?
    
    var body: some View {
        HStack(spacing: 0) {
            List(authors, selection: $selectedAuthor) { author in
                Text(author.name)
            }
            .frame(width: 200)
            
            if let author = selectedAuthor {
                HStack(spacing: 0) {
                    BrowseGrid(
                        cards: author.cards,
                        selectedCard: $selectedCard
                    )
                    
                    if let card = selectedCard {
                        Divider()
                        CardContentView(card: card)
                            .frame(width: 300)
                    }
                }
            } else {
                ContentUnavailableView(
                    "No Author Selected",
                    systemImage: "person",
                    description: Text("Select an author to view their cards")
                )
            }
            
            Divider()
        }
    }
}
