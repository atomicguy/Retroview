//
//  MainView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/20/24.
//

import SwiftData
import SwiftUI

struct MainView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \CollectionSchemaV1.Collection.name) private var collections: [CollectionSchemaV1.Collection]
    @State private var selectedDestination: AppDestination?
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationSplitView {
            Sidebar(selectedDestination: $selectedDestination)
        } detail: {
            NavigationStack(path: $navigationPath) {
                contentView
                    .navigationDestination(for: CardSchemaV1.StereoCard.self) { card in
                        CardDetailView(card: card)
                            .navigationTitle(card.titlePick?.text ?? "Card Details")
                    }
                    .navigationDestination(for: SubjectSchemaV1.Subject.self) { subject in
                        CardGridLayout(
                            cards: subject.cards,
                            selectedCard: .constant(nil),
                            onCardSelected: { card in
                                navigationPath.append(card)
                            }
                        )
                        .navigationTitle(subject.name)
                    }
                    .navigationDestination(for: AuthorSchemaV1.Author.self) { author in
                        CardGridLayout(
                            cards: author.cards,
                            selectedCard: .constant(nil),
                            onCardSelected: { card in
                                navigationPath.append(card)
                            }
                        )
                        .navigationTitle(author.name)
                    }
                    .navigationDestination(for: CollectionSchemaV1.Collection.self) { collection in
                        CollectionView(collection: collection)
                    }
            }
        }
    }
    
    @ViewBuilder
    private var contentView: some View {
        switch selectedDestination {
        case .none, .library:
            LibraryGridView(navigationPath: $navigationPath)
        case .subjects:
            SubjectsView(navigationPath: $navigationPath)
        case .authors:
            AuthorsView(navigationPath: $navigationPath)
        case let .collection(id, _):
            if let collection = collections.first(where: { $0.id == id }) {
                CollectionView(collection: collection)
            } else {
                ContentUnavailableView("Collection Not Found", systemImage: "exclamationmark.triangle")
            }
        }
    }
}

#Preview("Main View") {
    NavigationStack {
        MainView()
            .withPreviewContainer()
            .environment(\.imageLoader, CardImageLoader())
            .frame(width: 1024, height: 768)
    }
}
