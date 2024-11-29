//
//  CardHoverOverlay.swift
//  Retroview
//
//  Created by Adam Schuster on 11/28/24.
//

import SwiftUI

struct CardHoverOverlay: View {
    let card: CardSchemaV1.StereoCard
    @ObservedObject var viewModel: StereoCardViewModel
    @Binding var showingNewCollectionSheet: Bool
    let currentCollection: CollectionSchemaV1.Collection?
    @State private var showingMenu = false

    var displayTitle: String {
        card.titlePick?.text ?? card.titles.first?.text ?? "Untitled"
    }

    var body: some View {
        HStack {
            FavoriteButton(card: card)

            Spacer()

            Menu {
                CollectionMenuContent(
                    showNewCollectionSheet: $showingNewCollectionSheet,
                    card: card,
                    currentCollection: currentCollection
                )

                ShareLink(
                    item: displayTitle,
                    subject: Text("Stereoview Card"),
                    message: Text(card.titles.first?.text ?? ""),
                    preview: SharePreview(
                        displayTitle,
                        image: viewModel.frontCGImage.map {
                            Image(decorative: $0, scale: 1.0)
                        } ?? Image(systemName: "photo")
                    )
                )
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.title2)
                    .foregroundStyle(.white)
                    .shadow(radius: 2)
                    .contentTransition(.symbolEffect(.replace))
            }
            .menuStyle(.button)
            .buttonStyle(.plain)
        }
        .padding(12)
        .transition(.opacity)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }
}

#Preview {
    CardPreviewContainer { card in
        CardHoverOverlay(
            card: card,
            viewModel: StereoCardViewModel(stereoCard: card),
            showingNewCollectionSheet: .constant(false),
            currentCollection: nil
        )
        .frame(width: 300, height: 300)
        .background(Color.black.opacity(0.3))
    }
}

#Preview("In Collection") {
    CardPreviewContainer { card in
        CardHoverOverlay(
            card: card,
            viewModel: StereoCardViewModel(stereoCard: card),
            showingNewCollectionSheet: .constant(false),
            currentCollection: CollectionSchemaV1.Collection.preview
        )
        .frame(width: 300, height: 300)
        .background(Color.black.opacity(0.3))
    }
}
