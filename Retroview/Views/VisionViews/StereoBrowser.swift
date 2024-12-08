//
//  StereoBrowser.swift
//  Retroview
//
//  Created by Adam Schuster on 12/1/24.
//

import SwiftData
import SwiftUI

#if os(visionOS)
    struct StereoBrowser: View {
        let cards: [CardSchemaV1.StereoCard]
        @Binding var selectedCard: CardSchemaV1.StereoCard
        @Binding var isVisible: Bool
        let currentCollection: CollectionSchemaV1.Collection?
        @StateObject private var viewModel: StereoCardViewModel

        init(
            cards: [CardSchemaV1.StereoCard],
            selectedCard: Binding<CardSchemaV1.StereoCard>,
            isVisible: Binding<Bool>,
            currentCollection: CollectionSchemaV1.Collection?
        ) {
            self.cards = cards
            self._selectedCard = selectedCard
            self._isVisible = isVisible
            self.currentCollection = currentCollection
            self._viewModel = StateObject(
                wrappedValue: StereoCardViewModel(
                    stereoCard: selectedCard.wrappedValue,
                    imageService: ImageServiceFactory.shared.getService()
                ))
        }

        var body: some View {
            ZStack(alignment: .topLeading) {
                Button {
                    withAnimation(.spring) {
                        isVisible = false
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2.weight(.semibold))
                        .foregroundColor(.primary)
                        .padding(12)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .padding(20)
                .zIndex(1)

                VStack(spacing: 0) {
                    StyleStereoView(
                        card: selectedCard,
                        viewModel: viewModel
                    )
                    .id(selectedCard.uuid)
                    .frame(maxHeight: .infinity)

                    CenteredThumbnailStrip(
                        cards: cards,
                        selectedCard: selectedCard,
                        onSelect: { card in
                            withAnimation(.spring) {
                                selectedCard = card
                                // Update the viewModel's card
                                viewModel.stereoCard = card
                            }
                        }
                    )
                }
            }
        }
    }

#Preview {
    let descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
    let container = try! PreviewDataManager.shared.container()
    let cards = try! container.mainContext.fetch(descriptor)
    
    return StereoBrowser(
        cards: cards,
        selectedCard: .constant(cards[0]),
        isVisible: .constant(true),
        currentCollection: nil
    )
    .withPreviewData()
}
#endif
