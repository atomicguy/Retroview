//
//  AuthorsView.swift
//  Retroview
//
//  Created by Adam Schuster on 11/29/24.
//

import SwiftData
import SwiftUI

struct AuthorsView: View {
    @Query(sort: \AuthorSchemaV1.Author.name) private var authors: [AuthorSchemaV1.Author]
    @State private var selectedAuthor: AuthorSchemaV1.Author?
    @State private var selectedCard: CardSchemaV1.StereoCard?

    var body: some View {
        BrowseLayout(
            listContent: { authorsList },
            gridContent: { authorGrid },
            selectedCard: $selectedCard
        )
        .onChange(of: selectedAuthor) { _, _ in
            selectedCard = nil
        }
        .platformNavigationTitle("Authors")
    }

    private var authorsList: some View {
        List(authors) { author in
            AuthorRow(
                author: author,
                isSelected: selectedAuthor?.id == author.id,
                action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedAuthor = author
                    }
                }
            )
        }
    }

    private var authorGrid: some View {
        Group {
            if let author = selectedAuthor {
                CardGridView(
                    cards: author.cards,
                    selectedCard: $selectedCard,
                    currentCollection: nil,
                    title: "\(author.name) (\(author.cards.count) cards)"
                )
                .id(author.id)
            } else {
                ContentUnavailableView(
                    "No Author Selected",
                    systemImage: "person",
                    description: Text("Select an author to view their cards")
                )
            }
        }
        .animation(.easeInOut(duration: 0.3), value: selectedCard)
        .transition(.asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .top).combined(with: .opacity)
        ))
    }
}

private struct AuthorRow: View {
    let author: AuthorSchemaV1.Author
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        HStack {
            Text(author.name)

            if !author.cards.isEmpty {
                Text("\(author.cards.count)")
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: action)
        .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
    }
}

#Preview {
    AuthorsView()
        .withPreviewContainer()
        .frame(width: 1200, height: 800)
}
