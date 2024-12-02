////
////  StereoCollectionView.swift
////  Retroview
////
////  Created by Adam Schuster on 11/30/24.
////
//
// import SwiftData
// import SwiftUI
//
// #if os(visionOS)
//    struct StereoCollectionView: View {
//        @Query private var cards: [CardSchemaV1.StereoCard]
//        @State private var selectedCard: CardSchemaV1.StereoCard?
//
//        var body: some View {
//            VStack {
//                if let selectedCard {
//                    StereoView(card: selectedCard)
//                        .id(selectedCard.uuid)
//                        .toolbar(.hidden)
//                } else {
//                    ContentUnavailableView(
//                        "No Card Selected",
//                        systemImage: "photo.on.rectangle",
//                        description: Text("Select a card from the ornament below")
//                    )
//                }
//            }
//            .ornament(visibility: .visible, attachmentAnchor: .scene(.bottom)) {
//                StereoCardThumbnailOrnament(cards: cards) { card in
//                    selectedCard = card
//                }
//            }
//        }
//    }
//
//    #Preview("Stereo Gallery View") {
//        let container = PreviewContainer.shared.modelContainer
//
//        return StereoCollectionView()
//            .modelContainer(container)
//            .frame(width: 800, height: 600)
//    }
//
// #endif
