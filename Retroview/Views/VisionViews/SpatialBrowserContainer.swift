//
//  SpatialBrowserContainer.swift
//  Retroview
//
//  Created by Adam Schuster on 12/5/24.
//

import SwiftData
import SwiftUI

#if os(visionOS)
struct SpatialBrowserContainer<Content: View>: View {
    let cards: [CardSchemaV1.StereoCard]
    let content: Content
    @State private var selectedCard: CardSchemaV1.StereoCard?
    @State private var isViewerVisible = false
    @State private var visibleCards: [CardSchemaV1.StereoCard] = []
    
    init(cards: [CardSchemaV1.StereoCard], @ViewBuilder content: () -> Content) {
        self.cards = cards
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            content
                .opacity(isViewerVisible ? 0 : 1)
            
            if let selected = selectedCard {
                StereoBrowser(
                    cards: visibleCards,  // Use filtered cards instead of all cards
                    selectedCard: .init(
                        get: { selected },
                        set: { selectedCard = $0 }
                    ),
                    isVisible: $isViewerVisible,
                    currentCollection: nil
                )
                .opacity(isViewerVisible ? 1 : 0)
            }
        }
        .environment(\.spatialBrowserState, SpatialBrowserState(
            selectedCard: $selectedCard,
            isViewerVisible: $isViewerVisible,
            visibleCards: $visibleCards  // Add visibleCards to the environment
        ))
    }
}

struct SpatialBrowserState {
    let selectedCard: Binding<CardSchemaV1.StereoCard?>
    let isViewerVisible: Binding<Bool>
    let visibleCards: Binding<[CardSchemaV1.StereoCard]>
    
    func showBrowser(with card: CardSchemaV1.StereoCard, cards: [CardSchemaV1.StereoCard]) {
        selectedCard.wrappedValue = card
        visibleCards.wrappedValue = cards
        isViewerVisible.wrappedValue = true
    }
}

private struct SpatialBrowserStateKey: EnvironmentKey {
    static let defaultValue = SpatialBrowserState(
        selectedCard: .constant(nil),
        isViewerVisible: .constant(false),
        visibleCards: .constant([])
    )
}

extension EnvironmentValues {
    var spatialBrowserState: SpatialBrowserState {
        get { self[SpatialBrowserStateKey.self] }
        set { self[SpatialBrowserStateKey.self] = newValue }
    }
}

//// MARK: - Subject Detail View
//private struct SubjectDetailView: View {
//    let subject: SubjectSchemaV1.Subject
//    @Environment(\.spatialBrowserState) private var browserState
//    
//    var body: some View {
//        ScrollView {
//            LazyVGrid(columns: [GridItem(.adaptive(minimum: 250, maximum: 300))], spacing: 10) {
//                ForEach(subject.cards) { card in
//                    CardSquareView(card: card)
//                        .withTitle()
//                        .contentShape(Rectangle())
//                        .onTapGesture {
//                            browserState.showBrowser(with: card)
//                        }
//                }
//            }
//            .padding()
//        }
//        .navigationTitle("\(subject.name) (\(subject.cards.count) cards)")
//    }
//}

//// MARK: - Updated VisionAuthorsView
//struct VisionAuthorsView: View {
//    @Query(sort: \AuthorSchemaV1.Author.name) private var authors: [AuthorSchemaV1.Author]
//    @State private var selectedAuthor: AuthorSchemaV1.Author?
//    
//    var body: some View {
//        if let author = selectedAuthor {
//            SpatialBrowserContainer(cards: author.cards) {
//                NavigationSplitView {
//                    List(authors, selection: $selectedAuthor) { author in
//                        AuthorRow(author: author)
//                            .tag(author)
//                    }
//                    .navigationTitle("Authors")
//                } detail: {
//                    AuthorDetailView(author: author)
//                }
//            }
//        } else {
//            NavigationSplitView {
//                List(authors, selection: $selectedAuthor) { author in
//                    AuthorRow(author: author)
//                        .tag(author)
//                }
//                .navigationTitle("Authors")
//            } detail: {
//                ContentUnavailableView(
//                    "No Author Selected",
//                    systemImage: "person",
//                    description: Text("Select an author to view their cards")
//                )
//            }
//        }
//    }
//}

//// MARK: - Author Detail View
//private struct AuthorDetailView: View {
//    let author: AuthorSchemaV1.Author
//    @Environment(\.spatialBrowserState) private var browserState
//    
//    var body: some View {
//        ScrollView {
//            LazyVGrid(columns: [GridItem(.adaptive(minimum: 250, maximum: 300))], spacing: 10) {
//                ForEach(author.cards) { card in
//                    CardSquareView(card: card)
//                        .withTitle()
//                        .contentShape(Rectangle())
//                        .onTapGesture {
//                            browserState.showBrowser(with: card)
//                        }
//                }
//            }
//            .padding()
//        }
//        .navigationTitle("\(author.name) (\(author.cards.count) cards)")
//    }
//}
#endif

//struct SpatialBrowserContainer_Previews: PreviewProvider {
//    // Sample content view to demonstrate container usage
//    private struct PreviewContentView: View {
//        @Environment(\.spatialBrowserState) private var browserState
//        let cards: [CardSchemaV1.StereoCard]
//        
//        var body: some View {
//            NavigationStack {
//                ScrollView {
//                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 250))], spacing: 10) {
//                        ForEach(cards) { card in
//                            CardSquareView(card: card)
//                                .withTitle()
//                                .onTapGesture {
//                                    browserState.showBrowser(with: card)
//                                }
//                        }
//                    }
//                    .padding()
//                }
//                .navigationTitle("Preview Content")
//            }
//        }
//    }
//    
//    static var previews: some View {
//        CardsPreviewContainer { cards in
//            SpatialBrowserContainer(cards: cards) {
//                PreviewContentView(cards: cards)
//            }
//        }
//        .previewDisplayName("With Sample Content")
//    }
//}
