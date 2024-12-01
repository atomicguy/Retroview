//
//  CollectionThumbnailView.swift
//  Retroview
//
//  Created by Adam Schuster on 11/30/24.
//

import SwiftData
import SwiftUI

#if os(visionOS)
    struct CollectionThumbnailView: View {
        let collection: CollectionSchemaV1.Collection
        @Environment(\.modelContext) private var modelContext

        private var previewCards: [CardSchemaV1.StereoCard] {
            collection.fetchCards(context: modelContext)
        }

        var body: some View {
            VStack(spacing: 0) {
                HStack(spacing: 4) {
                    ForEach(previewCards.prefix(4)) { card in
                        ThumbnailItem(card: card)
                            .frame(height: 60)
                    }

                    ForEach(0 ..< max(0, 4 - previewCards.count), id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.secondary.opacity(0.2))
                            .frame(height: 60)
                    }
                }
                .padding(8)

                ZStack {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .aspectRatio(16 / 10, contentMode: .fit)

                    Text(collection.name)
                        .font(.system(.headline, design: .serif))
                        .foregroundStyle(.primary)
                }
            }
            .background(.ultraThickMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(radius: 5)
        }
    }

    private struct ThumbnailItem: View {
        let card: CardSchemaV1.StereoCard
        @StateObject private var viewModel: StereoCardViewModel

        init(card: CardSchemaV1.StereoCard) {
            self.card = card
            _viewModel = StateObject(wrappedValue: StereoCardViewModel(stereoCard: card))
        }

        var body: some View {
            ZStack {
                if let image = viewModel.frontCGImage {
                    Image(decorative: image, scale: 1.0)
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    ProgressView()
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .task {
                try? await viewModel.loadImage(forSide: "front")
            }
        }
    }

    #Preview {
        CardPreviewContainer { card in
            let collection = CollectionSchemaV1.Collection(name: "Preview Collection", cards: [card])
            return CollectionThumbnailView(collection: collection)
                .frame(width: 400, height: 200)
        }
    }
#endif
