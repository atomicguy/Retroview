//
//  CardDetailView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/15/24.
//

import SwiftData
import SwiftUI

#if os(visionOS)
    import QuickLook
#endif

struct CardDetailView: View {
    @Bindable var card: CardSchemaV1.StereoCard
    @Environment(\.modelContext) private var modelContext
    @Environment(\.imageLoader) private var imageLoader
    @State private var showCrops = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                if card.imageFrontId != nil {
                    ZStack {
                        CardImageSection(
                            card: card,
                            side: .front,
                            title: "Front",
                            showCrops: showCrops
                        )

                        GeometryReader { geometry in
                            VStack {
                                HStack {
                                    Spacer()
                                    #if os(visionOS)
                                        Button(action: handleViewInSpace) {
                                            Image(systemName: "view.3d")
                                                .overlayButtonStyle(
                                                    opacity: 1.0)
                                        }
                                        .padding(.trailing, 8)
                                        .padding(.top, 34)
                                        .buttonStyle(.plain)
                                    #endif
                                }
                                Spacer()
                                HStack {
                                    FavoriteButton(card: card)
                                        .padding(8)
                                    Spacer()
                                    CropButton(showCrops: $showCrops)
                                        .padding(8)
                                }
                            }
                            .frame(
                                width: geometry.size.width,
                                height: geometry.size.height)
                        }
                    }
                }

                if !card.subjects.isEmpty {
                    SubjectsSection(subjects: card.subjects)
                }
                
                CardTitlesSection(card: card) { title in
                    guard title != card.titlePick else { return }
                    card.titlePick = title
                    try? modelContext.save()
                }
                
                if !card.dates.isEmpty {
                    DatesSection(dates: card.dates)
                }
                
                if !card.authors.isEmpty {
                    AuthorsSection(authors: card.authors)
                }

                if card.imageBackId != nil {
                    CardImageSection(card: card, side: .back, title: "Back")
                }

                Divider()

                NYPLCollectionLink(cardUUID: card.uuid)
                    .padding(.bottom)
            }
            .padding()
        }
    }

    private func handleViewInSpace() {
        #if os(visionOS)
            Task {
                guard let imageLoader = imageLoader else { return }
                await card.viewInSpace(imageLoader: imageLoader)
            }
        #endif
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
