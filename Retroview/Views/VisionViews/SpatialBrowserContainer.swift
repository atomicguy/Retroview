////
////  SpatialBrowserContainer.swift
////  Retroview
////
////  Created by Adam Schuster on 12/5/24.
////
//
//import SwiftData
//import SwiftUI
//
//#if os(visionOS)
//    struct SpatialBrowserContainer<Content: View>: View {
//        let cards: [CardSchemaV1.StereoCard]
//        let content: Content
//        @State private var selectedCard: CardSchemaV1.StereoCard?
//        @State private var isViewerVisible = false
//        @State private var visibleCards: [CardSchemaV1.StereoCard] = []
//
//        init(
//            cards: [CardSchemaV1.StereoCard],
//            @ViewBuilder content: () -> Content
//        ) {
//            self.cards = cards
//            self.content = content()
//        }
//
//        var body: some View {
//            ZStack {
//                content
//                    .opacity(isViewerVisible ? 0 : 1)
//
//                if let selected = selectedCard {
//                    StereoBrowser(
//                        cards: visibleCards,  // Use filtered cards instead of all cards
//                        selectedCard: .init(
//                            get: { selected },
//                            set: { selectedCard = $0 }
//                        ),
//                        isVisible: $isViewerVisible,
//                        currentCollection: nil
//                    )
//                    .opacity(isViewerVisible ? 1 : 0)
//                }
//            }
//            .environment(
//                \.spatialBrowserState,
//                SpatialBrowserState(
//                    selectedCard: $selectedCard,
//                    isViewerVisible: $isViewerVisible,
//                    visibleCards: $visibleCards  // Add visibleCards to the environment
//                ))
//        }
//    }
//
//    struct SpatialBrowserState {
//        let selectedCard: Binding<CardSchemaV1.StereoCard?>
//        let isViewerVisible: Binding<Bool>
//        let visibleCards: Binding<[CardSchemaV1.StereoCard]>
//
//        func showBrowser(
//            with card: CardSchemaV1.StereoCard, cards: [CardSchemaV1.StereoCard]
//        ) {
//            selectedCard.wrappedValue = card
//            visibleCards.wrappedValue = cards
//            isViewerVisible.wrappedValue = true
//        }
//    }
//
//    private struct SpatialBrowserStateKey: EnvironmentKey {
//        static let defaultValue = SpatialBrowserState(
//            selectedCard: .constant(nil),
//            isViewerVisible: .constant(false),
//            visibleCards: .constant([])
//        )
//    }
//
//    extension EnvironmentValues {
//        var spatialBrowserState: SpatialBrowserState {
//            get { self[SpatialBrowserStateKey.self] }
//            set { self[SpatialBrowserStateKey.self] = newValue }
//        }
//    }
//
//    #Preview("Spatial Browser") {
//        let descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
//        let container = try! PreviewDataManager.shared.container()
//        let cards = try! container.mainContext.fetch(descriptor)
//
//        return SpatialBrowserContainer(cards: cards) {
//            Text("Preview Content")
//        }
//        .withPreviewData()
//    }
//#endif
