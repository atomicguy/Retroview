//
//  CardDetailView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/15/24.
//

import SwiftData
import SwiftUI

struct CardDetailView: View {
    @Environment(\.modelContext) private var modelContext
    let card: CardSchemaV1.StereoCard

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                CardHeaderView(card: card)

                if card.imageFrontId != nil {
                    CardImageSection(card: card, side: .front, title: "Front")
                }

                if !card.subjects.isEmpty {
                    CardSubjectSection(subjects: card.subjects)
                }

                if card.imageBackId != nil {
                    CardImageSection(card: card, side: .back, title: "Back")
                }

                CardTitleSection(card: card) { title in
                    guard title != card.titlePick else { return }
                    do {
                        card.titlePick = title
                        try modelContext.save()
                    } catch {
                        print("Failed to update title pick: \(error)")
                    }
                }

                if !card.collections.isEmpty {
                    metadataSection("Collections") {
                        ForEach(card.collections) { collection in
                            NavigationLink(value: collection) {
                                CollectionRow(collection: collection)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .platformNavigationTitle(
            card.titlePick?.text ?? "Untitled Card", displayMode: .inline
        )
        .platformToolbar {
            FavoriteButton(card: card)
        } trailing: {
            CollectionMenuButton(card: card)
        }
    }

    private func metadataSection<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(.headline, design: .serif))
            content()
        }
    }
}

private struct CollectionRow: View {
    let collection: CollectionSchemaV1.Collection

    var body: some View {
        HStack {
            Text(collection.name)
            Spacer()
            Image(
                systemName: CollectionDefaults.isFavorites(collection)
                    ? "heart.fill" : "folder")
        }
        .padding(8)
        .background(.secondary.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
