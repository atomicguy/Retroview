//
//  CardSquareView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/2/24.
//

import SwiftData
import SwiftUI

struct CardSquareView: View {
    let card: CardSchemaV1.StereoCard
    @StateObject private var viewModel: StereoCardViewModel

    init(card: CardSchemaV1.StereoCard) {
        self.card = card
        _viewModel = StateObject(
            wrappedValue: StereoCardViewModel(
                stereoCard: card,
                imageService: ImageServiceFactory.shared.getService()
            )
        )
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
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
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipped()
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [
                    card.color,
                    card.color.opacity(card.colorOpacity * 1),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(
            color: card.color.opacity(0.5),
            radius: 8,
            x: 0,
            y: 4
        )
        .task(priority: .high) {
            try? await viewModel.loadImage(forSide: "front")
        }
        
    }
}

// MARK: - Title Modifier

struct CardTitleModifier: ViewModifier {
    let title: String

    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            content

            Text(title)
                .font(.system(.subheadline, design: .serif))
                .lineLimit(2)
                .truncationMode(.tail)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(.ultraThickMaterial)
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct CardInteractiveModifier: ViewModifier {
    let card: CardSchemaV1.StereoCard
    let onSelect: ((CardSchemaV1.StereoCard) -> Void)?
    @State private var showingNewCollectionSheet = false

    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())
            .onTapGesture {
                onSelect?(card)
            }
            .withCardInteraction { isActive in
                if isActive {
                    CardHoverOverlay(
                        card: card,
                        viewModel: StereoCardViewModel(stereoCard: card),
                        showingNewCollectionSheet: $showingNewCollectionSheet,
                        currentCollection: nil
                    )
                }
            }
            .draggable(card)
            .contextMenu {
                CollectionMenuContent(
                    showNewCollectionSheet: $showingNewCollectionSheet,
                    card: card,
                    currentCollection: nil
                )
            }
            .sheet(isPresented: $showingNewCollectionSheet) {
                NewCollectionSheet(card: card)
            }
    }
}

// MARK: - View Extensions

extension View {
    func withCardTitle(_ title: String) -> some View {
        modifier(CardTitleModifier(title: title))
    }

    func cardInteractive(
        card: CardSchemaV1.StereoCard,
        currentCollection: CollectionSchemaV1.Collection? = nil,
        onSelect: ((CardSchemaV1.StereoCard) -> Void)? = nil
    ) -> some View {
        modifier(
            CardInteractiveModifier(
                card: card,
                onSelect: onSelect
            ))
    }
}

// MARK: - CardSquareView Extensions

extension CardSquareView {
    func withTitle() -> some View {
        withCardTitle(
            card.titlePick?.text ?? card.titles.first?.text ?? "Untitled")
    }

    func interactive(
        currentCollection: CollectionSchemaV1.Collection? = nil,
        onSelect: ((CardSchemaV1.StereoCard) -> Void)? = nil
    ) -> some View {
        cardInteractive(
            card: card,
            currentCollection: currentCollection,
            onSelect: onSelect
        )
    }
}

// MARK: - Previews

#Preview("Card Square View") {
    CardPreviewContainer { card in
        CardSquareView(card: card)
            .frame(width: 300)
            .padding()
    }
}

#Preview("Basic CardSquareView") {
    let descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
    let container = try! PreviewDataManager.shared.container()
    let card = try! container.mainContext.fetch(descriptor).first!
    
    return CardSquareView(card: card)
        .frame(width: 300)
        .padding()
        .withPreviewData()
}

#Preview("With Title") {
    let descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
    let container = try! PreviewDataManager.shared.container()
    let card = try! container.mainContext.fetch(descriptor).first!
    
    return CardSquareView(card: card)
        .withTitle()
        .frame(width: 300)
        .padding()
        .withPreviewData()
}

#Preview("Interactive") {
    let descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
    let container = try! PreviewDataManager.shared.container()
    let card = try! container.mainContext.fetch(descriptor).first!
    
    let collectionDescriptor = FetchDescriptor<CollectionSchemaV1.Collection>(
        predicate: #Predicate<CollectionSchemaV1.Collection> { collection in
            collection.name == "World's Fair"
        }
    )
    let collection = try! container.mainContext.fetch(collectionDescriptor).first!
    
    return CardSquareView(card: card)
        .withTitle()
        .cardInteractive(
            card: card,
            currentCollection: collection,
            onSelect: { _ in }
        )
        .frame(width: 300)
        .padding()
        .withPreviewData()
}
