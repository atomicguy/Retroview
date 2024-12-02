//
//  CollectionContentGridView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/1/24.
//

import SwiftUI
import SwiftData

struct CollectionContentGridView<T: Identifiable>: View {
    let title: String
    let items: [CardSchemaV1.StereoCard]
    @Binding var selectedCard: CardSchemaV1.StereoCard?
    let parentId: T.ID
    
    var body: some View {
        CardGridView(
            cards: items,
            selectedCard: $selectedCard,
            currentCollection: nil,
            title: title
        )
        .id(parentId)
        .animation(.easeInOut(duration: 0.3), value: selectedCard)
        .transition(.asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .top).combined(with: .opacity)
        ))
    }
}

// Specialized view for Subjects
struct SubjectGridView: View {
    let subject: SubjectSchemaV1.Subject
    @Binding var selectedCard: CardSchemaV1.StereoCard?
    
    var body: some View {
        CollectionContentGridView<SubjectSchemaV1.Subject>(
            title: "\(subject.name) (\(subject.cards.count) cards)",
            items: subject.cards,
            selectedCard: $selectedCard,
            parentId: subject.id
        )
    }
}

// Specialized view for Authors
struct AuthorGridView: View {
    let author: AuthorSchemaV1.Author
    @Binding var selectedCard: CardSchemaV1.StereoCard?
    
    var body: some View {
        CollectionContentGridView<AuthorSchemaV1.Author>(
            title: "\(author.name) (\(author.cards.count) cards)",
            items: author.cards,
            selectedCard: $selectedCard,
            parentId: author.id
        )
    }
}

// Preview-specific mock identifiable type
private struct PreviewItem: Identifiable {
    let id = UUID()
}

#Preview("Collection Grid") {
    let previewItem = PreviewItem()
    return CardPreviewContainer { card in
        CollectionContentGridView<PreviewItem>(
            title: "Preview Collection",
            items: [card],
            selectedCard: .constant(nil),
            parentId: previewItem.id
        )
        .frame(width: 1200, height: 800)
    }
} 
