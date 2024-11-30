//
//  SquareCropView.swift
//  Retroview
//
//  Created by Adam Schuster on 11/26/24.
//

import CoreGraphics
import SwiftData
import SwiftUI

struct SquareCropView: View {
    @Bindable var card: CardSchemaV1.StereoCard
    @StateObject private var viewModel: StereoCardViewModel
    @State private var showingNewCollectionSheet = false
    let currentCollection: CollectionSchemaV1.Collection?

    init(card: CardSchemaV1.StereoCard, currentCollection: CollectionSchemaV1.Collection? = nil) {
        self.card = card
        self.currentCollection = currentCollection
        _viewModel = StateObject(wrappedValue: StereoCardViewModel(stereoCard: card))
    }

    var displayTitle: String {
        card.titlePick?.text ?? card.titles.first?.text ?? "Untitled"
    }

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            GeometryReader { geometry in
                if let image = viewModel.frontCGImage,
                   let leftCrop = card.leftCrop
                {
                    let cropWidth = CGFloat(leftCrop.y1 - leftCrop.y0)
                    let cropHeight = CGFloat(leftCrop.x1 - leftCrop.x0)
                    let scale = min(
                        geometry.size.width / (cropWidth * CGFloat(image.width)),
                        geometry.size.height / (cropHeight * CGFloat(image.height))
                    )

                    Image(decorative: image, scale: 1.0)
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: CGFloat(image.width) * scale,
                            height: CGFloat(image.height) * scale
                        )
                        .offset(
                            x: -CGFloat(leftCrop.y0) * CGFloat(image.width) * scale,
                            y: -CGFloat(leftCrop.x0) * CGFloat(image.height) * scale
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .aspectRatio(1, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 12))

            Text(displayTitle)
                .font(.system(.subheadline, design: .serif))
                .lineLimit(2)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            LinearGradient(
                colors: [
                    card.color,
                    card.color.opacity(card.colorOpacity * 0.7),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .squareAspectRatio()
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(
            color: card.color.opacity(0.5),
            radius: 8,
            x: 0,
            y: 4
        )
        .withCardInteraction { isActive in
            if isActive {
                CardHoverOverlay(
                    card: card,
                    viewModel: viewModel,
                    showingNewCollectionSheet: $showingNewCollectionSheet,
                    currentCollection: currentCollection
                )
            }
        }
        .task(priority: .high) {
            await withTaskGroup(of: Void.self) { group in
                group.addTask {
                    try? await viewModel.loadImage(forSide: "front")
                }

                group.addTask {
                    try? await viewModel.loadImage(forSide: "back")
                }

                await group.waitForAll()
            }
        }
        .draggable(card)
        .contextMenu {
            CollectionMenuContent(
                showNewCollectionSheet: $showingNewCollectionSheet,
                card: card,
                currentCollection: currentCollection
            )
        }
        .sheet(isPresented: $showingNewCollectionSheet) {
            NewCollectionSheet(card: card)
        }
    }
}

#Preview("Square Crop View") {
    CardPreviewContainer { card in
        SquareCropView(card: card)
            .frame(width: 300)
            .padding()
    }
}

#Preview("Square Crop View in Collection") {
    CardPreviewContainer { card in
        SquareCropView(
            card: card,
            currentCollection: CollectionSchemaV1.Collection.preview
        )
        .frame(width: 300)
        .padding()
    }
}
