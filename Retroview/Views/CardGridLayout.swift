//
//  CardGridGroup.swift
//  Retroview
//
//  Created by Adam Schuster on 12/20/24.
//

import SwiftData
import SwiftUI

struct CardGridLayout: View {
    @Bindable var collection: CollectionSchemaV1.Collection
    let cards: [CardSchemaV1.StereoCard]
    @Binding var selectedCard: CardSchemaV1.StereoCard?
    @Binding var navigationPath: NavigationPath
    let onCardSelected: (CardSchemaV1.StereoCard) -> Void

    private var columns: [GridItem] {
        [
            GridItem(
                .adaptive(
                    minimum: PlatformEnvironment.Metrics.gridMinWidth,
                    maximum: PlatformEnvironment.Metrics.gridMaxWidth
                ), spacing: 20)
        ]
    }

    var body: some View {
        VStack(spacing: 0) {
            // Editable Collection Name with @Bindable collection
            HStack {
                if CollectionDefaults.isFavorites(collection) {
                    Text(collection.name)
                        .font(.system(.title, design: .serif))
                        .frame(maxWidth: .infinity)
                } else {
                    TextField("Collection Name", text: $collection.name)
                        .font(.system(.title, design: .serif))
                        .textFieldStyle(.plain)
                        .multilineTextAlignment(.center).background(
                            collection.name == "Untitled" ? Color.accentColor.opacity(0.3) : Color.clear
                        )
                }
            }
            .padding()
            .background(Color.secondary.opacity(0.1))

            // Rest of the view remains the same
            ScrollView {
                LazyVGrid(
                    columns: columns,
                    spacing: PlatformEnvironment.Metrics.gridSpacing
                ) {
                    ForEach(cards) { card in
                        ThumbnailSelectableView(
                            card: card,
                            isSelected: card.id == selectedCard?.id,
                            onSelect: { selectedCard = card },
                            onDoubleClick: {
                                navigationPath.append(
                                    CardDetailDestination.stack(
                                        cards: cards,
                                        initialCard: card
                                    ))
                            }
                        )
                    }
                }
                .padding(PlatformEnvironment.Metrics.defaultPadding)
            }
            .environment(\.currentCollection, collection)
        }
        .platformToolbar {
            EmptyView()
        } trailing: {
            #if os(visionOS)
                StereoGalleryButton(
                    cards: cards,
                    selectedCard: selectedCard
                )
            #endif
        }
    }
}
