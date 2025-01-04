//
//  CardDetailView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/15/24.
//

import SwiftData
import SwiftUI

struct CardDetailView: View {
    @Bindable var card: CardSchemaV1.StereoCard
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                CardHeaderView(card: card)

                if card.imageFrontId != nil {
                    CardImageSection(card: card, side: .front, title: "Front")
                }

                if !card.subjects.isEmpty {
                    MetadataSection(title: "Subjects") {
                        FlowLayoutView {
                            ForEach(card.subjects) { subject in
                                NavigationLink(value: subject) {
                                    SubjectBadge(name: subject.name)
                                }
                            }
                        }
                    }
                }

                if card.imageBackId != nil {
                    CardImageSection(card: card, side: .back, title: "Back")
                }

                CardTitleSection(card: card) { title in
                    guard title != card.titlePick else { return }
                    card.titlePick = title
                    try? modelContext.save()
                }

                if !card.collections.isEmpty {
                    MetadataSection(title: "Collections") {
                        ForEach(card.collections) { collection in
                            NavigationLink(value: collection) {
                                CollectionRow(collection: collection)
                            }
                        }
                    }
                }

                Divider()

                NYPLCollectionLink(cardUUID: card.uuid)
                    .padding(.bottom)
            }
            .padding()
        }
        .platformNavigationTitle(
            card.titlePick?.text ?? "Untitled Card",
            displayMode: .inline
        )
        .platformToolbar {
            FavoriteButton(card: card)
        } trailing: {
            CardActionMenu(card: card, showDirectMenu: .constant(false))
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

#Preview("Card Detail View") {
    NavigationStack {
        Group {
            if let card = try? PreviewDataManager.shared.container().mainContext
                .fetch(FetchDescriptor<CardSchemaV1.StereoCard>()).first
            {
                CardDetailView(card: card)
            } else {
                ContentUnavailableView("No Preview Card", systemImage: "photo")
            }
        }
        .withPreviewStore()
        .environment(\.imageLoader, CardImageLoader())
    }
}
