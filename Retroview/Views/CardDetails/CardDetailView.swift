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
    @State private var showCrops = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                CardHeaderView(card: card)

                if card.imageFrontId != nil {
                    CardImageSection(
                        card: card,
                        side: .front,
                        title: "Front",
                        showCrops: showCrops)
                }

                if !card.subjects.isEmpty {
                    CardSubjectSection(subjects: card.subjects)
                }

                if card.imageBackId != nil {
                    CardImageSection(
                        card: card,
                        side: .back,
                        title: "Back")
                }

                CardTitlesSection(card: card) { title in
                    guard title != card.titlePick else { return }
                    card.titlePick = title
                    try? modelContext.save()
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
        } trailing: {
            CropButton(showCrops: $showCrops)
            CardActionMenu(card: card, showDirectMenu: .constant(false))
            FavoriteButton(card: card)
        }
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
