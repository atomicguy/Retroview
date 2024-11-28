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

    init(card: CardSchemaV1.StereoCard) {
        self.card = card
        _viewModel = StateObject(
            wrappedValue: StereoCardViewModel(stereoCard: card))
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
                        geometry.size.width
                            / (cropWidth * CGFloat(image.width)),
                        geometry.size.height
                            / (cropHeight * CGFloat(image.height))
                    )

                    Image(decorative: image, scale: 1.0)
                        .resizable()
                        .scaledToFill()
                        .frame(
                            width: CGFloat(image.width) * scale,
                            height: CGFloat(image.height) * scale
                        )
                        .offset(
                            x: -CGFloat(leftCrop.y0) * CGFloat(image.width)
                                * scale,
                            y: -CGFloat(leftCrop.x0) * CGFloat(image.height)
                                * scale
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)  // Center in GeometryReader
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
                .multilineTextAlignment(.center)  // Center align text
                .frame(maxWidth: .infinity)  // Make text use full width
        }
        .frame(maxWidth: .infinity)  // Ensure VStack takes full width
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
            CollectionMenu(
                showNewCollectionSheet: $showingNewCollectionSheet, card: card)

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
        }
        .sheet(isPresented: $showingNewCollectionSheet) {
            NewCollectionSheet(card: card)
        }
    }
}

struct CollectionMenu: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CollectionSchemaV1.Collection.name) private var collections: [CollectionSchemaV1.Collection]
    @Binding var showNewCollectionSheet: Bool
    
    let card: CardSchemaV1.StereoCard
    
    var body: some View {
        if collections.isEmpty {
            Text("No Collections")
                .foregroundStyle(.secondary)
        } else {
            ForEach(collections) { collection in
                Button {
                    toggleCard(in: collection)
                } label: {
                    if collection.hasCard(card) {
                        Label(collection.name, systemImage: "checkmark.circle.fill")
                    } else {
                        Label(collection.name, systemImage: "circle")
                    }
                }
            }
            
            Divider()
        }
        
        Button {
            showNewCollectionSheet = true
        } label: {
            Label("New Collection...", systemImage: "folder.badge.plus")
        }
    }
    
    private func toggleCard(in collection: CollectionSchemaV1.Collection) {
        if collection.hasCard(card) {
            collection.removeCard(card)
        } else {
            collection.addCard(card)
        }
        try? modelContext.save()
    }
}

#Preview("Square Crop View") {
    CardPreviewContainer { card in
        SquareCropView(card: card)
            .frame(width: 300)
            .padding()
    }
}
