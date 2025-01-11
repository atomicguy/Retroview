//
//  CardActionMenu.swift
//  Retroview
//
//  Created by Adam Schuster on 1/1/25.
//

import SwiftData
import SwiftUI

struct CardActionMenu: View {
    let card: CardSchemaV1.StereoCard
    let isContextMenu: Bool

    init(card: CardSchemaV1.StereoCard, isContextMenu: Bool = false) {
        self.card = card
        self.isContextMenu = isContextMenu
    }

    var body: some View {
        if isContextMenu {
            MenuContent(card: card)
        } else {
            Menu {
                MenuContent(card: card, includeShare: false)
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.title2)
            }
        }
    }
}

// Usage methods that make it clear which version we're using
extension CardActionMenu {
    static func asButton(card: CardSchemaV1.StereoCard) -> CardActionMenu {
        CardActionMenu(card: card, isContextMenu: false)
    }

    static func asContextMenu(card: CardSchemaV1.StereoCard) -> CardActionMenu {
        CardActionMenu(card: card, isContextMenu: true)
    }
}

// MARK: - Shared Menu Content
private struct MenuContent: View {
    let card: CardSchemaV1.StereoCard
    let includeShare: Bool
    @State private var showNewCollectionSheet = false
    @Environment(\.imageLoader) private var imageLoader  // Add imageLoader environment

    init(card: CardSchemaV1.StereoCard, includeShare: Bool = true) {
        self.card = card
        self.includeShare = includeShare
    }

    var body: some View {
        Group {
            if includeShare {
                CardShareButton(card: card)
            }

            #if os(visionOS)
                VisionSpaceButton(card: card)  // Now has access to imageLoader via environment
            #endif

            CollectionSubmenu(
                card: card,
                showNewCollectionSheet: $showNewCollectionSheet
            )
        }
        .sheet(isPresented: $showNewCollectionSheet) {
            CollectionCreationView(card: card)
        }
    }
}

private struct CollectionSubmenu: View {
    let card: CardSchemaV1.StereoCard
    @Binding var showNewCollectionSheet: Bool

    var body: some View {
        Menu {
            CardCollectionOptions(
                card: card,
                showNewCollectionSheet: $showNewCollectionSheet
            )
        } label: {
            Label("Add to Collection", systemImage: "folder")
        }
    }
}

#Preview("Direct Menu") {
    CardPreviewContainer { card in
        CardActionMenu.asButton(card: card)
    }
}

#Preview("Button Menu") {
    CardPreviewContainer { card in
        CardActionMenu.asContextMenu(card: card)
    }
}
