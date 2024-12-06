//
//  BrowseView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/2/24.
//

import SwiftUI

struct BrowseView<T: CardGrouping>: View {
    @StateObject var viewModel: BrowseViewModel<T>
    let title: String

    var body: some View {
        #if os(visionOS)
            visionLayout
        #else
            desktopLayout
        #endif
    }

    // MARK: - Platform-specific layouts

    private var visionLayout: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))], spacing: 20) {
                    ForEach(viewModel.collections) { collection in
                        GroupingPreview(
                            collection: collection,
                            isSelected: viewModel.selectedCollection?.id == collection.id
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.navigate(to: collection)
                        }
                    }
                }
                .padding()
            }
            .navigationDestination(isPresented: $viewModel.isNavigating) {
                if let navigatingTo = viewModel.navigatingToCollection {
                    CardGroupingGrid(
                        cards: navigatingTo.cards,
                        selectedCard: $viewModel.selectedCard
                    )
                    .navigationTitle(navigatingTo.name)
                }
            }
            .navigationTitle(title)
        }
    }

    private var desktopLayout: some View {
        HStack(spacing: 0) {
            // Collections List
            List(viewModel.collections, selection: $viewModel.selectedCollection) { collection in
                GroupingPreview(
                    collection: collection,
                    isSelected: viewModel.selectedCollection?.id == collection.id
                )
                .tag(collection)
                .frame(height: 280)
            }
            .frame(width: 280)

            Divider()

            // Cards Grid
            if let selectedCollection = viewModel.selectedCollection {
                CardGroupingGrid(
                    cards: selectedCollection.cards,
                    selectedCard: $viewModel.selectedCard
                )
                .frame(maxWidth: .infinity)
            } else {
                ContentUnavailableView(
                    "No Collection Selected",
                    systemImage: "photo.on.rectangle",
                    description: Text("Select a collection to view its cards")
                )
                .frame(maxWidth: .infinity)
            }

            Divider()

            // Card Details
            Group {
                if let selectedCard = viewModel.selectedCard {
                    CardContentView(card: selectedCard)
                        .id(selectedCard.uuid)
                        .transition(.move(edge: .trailing))
                } else {
                    ContentUnavailableView(
                        "No Card Selected",
                        systemImage: "photo.on.rectangle",
                        description: Text("Select a card to view its details")
                    )
                    .transition(.opacity)
                }
            }
            .frame(width: 300)
            .animation(.smooth, value: viewModel.selectedCard)
        }
    }
}

// MARK: - Selection Handling
private struct CardSelectionModifier: ViewModifier {
    let onSelect: (CardSchemaV1.StereoCard) -> Void
    
    func body(content: Content) -> some View {
        #if os(visionOS)
        content
        #else
        content.environment(\.onCardSelect, onSelect)
        #endif
    }
}

private struct CardSelectionKey: EnvironmentKey {
    static let defaultValue: (CardSchemaV1.StereoCard) -> Void = { _ in }
}

private extension EnvironmentValues {
    var onCardSelect: (CardSchemaV1.StereoCard) -> Void {
        get { self[CardSelectionKey.self] }
        set { self[CardSelectionKey.self] = newValue }
    }
}

extension View {
    func onSelectCard(perform action: @escaping (CardSchemaV1.StereoCard) -> Void) -> some View {
        modifier(CardSelectionModifier(onSelect: action))
    }
}

#Preview("Browse View - Desktop") {
    BrowseView(
        viewModel: BrowseViewModel(
            collections: [
                PreviewContainer.shared.worldsFairCollection,
                PreviewContainer.shared.naturalWondersCollection,
            ]
        ),
        title: "Browse Subjects"
    )
    .withPreviewContainer()
    .frame(width: 1200, height: 800)
}

#Preview("Browse View - Vision") {
    BrowseView(
        viewModel: BrowseViewModel(
            collections: [
                PreviewContainer.shared.worldsFairCollection,
                PreviewContainer.shared.naturalWondersCollection,
            ]
        ),
        title: "Browse Subjects"
    )
    .withPreviewContainer()
}
