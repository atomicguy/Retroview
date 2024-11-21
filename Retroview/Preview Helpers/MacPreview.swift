//
//  MacPreview.swift
//  Retroview
//
//  Created by Adam Schuster on 11/19/24.
//

import SwiftUI
import SwiftData

// MARK: - Preview Helper Extension
extension PreviewHelper {
    var previewGroups: [CardGroupSchemaV1.Group] {
        createSampleGroups()
    }
    
    private func createSampleGroups() -> [CardGroupSchemaV1.Group] {
        let sampleGroups = [
            ("World's Fair Highlights", [0]),
            ("Architecture", [0, 1]),
            ("Favorites", [1])
        ]
        
        return sampleGroups.map { name, indices in
            let cards = indices.map { CardSchemaV1.StereoCard.sampleData[$0] }
            let group = CardGroupSchemaV1.Group(name: name, cards: cards)
            modelContainer.mainContext.insert(group)
            return group
        }
    }
}

// MARK: - Preview Container
struct MacBrowserPreviewContainer<Content: View>: View {
    let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        content()
            .modelContainer(PreviewHelper.shared.modelContainer)
            .frame(width: 1200, height: 800)
    }
}

// MARK: - Previews
#Preview("Mac Browser - Full Window") {
    MacBrowserView()
        .modelContainer(PreviewHelper.shared.modelContainer)
        .frame(width: 1200, height: 800)
}

#Preview("Sidebar") {
    SidebarView(
        filter: .constant(CardFilter()),
        groups: PreviewHelper.shared.previewGroups,
        selectedGroup: nil,
        onGroupSelect: { _ in }
    )
    .frame(width: 250)
    .modelContainer(PreviewHelper.shared.modelContainer)
}

#Preview("Card Browser") {
    CardBrowserView(
        cards: PreviewHelper.shared.previewCards,
        selectedCards: .constant([]),
        onCreateGroup: {}
    )
    .modelContainer(PreviewHelper.shared.modelContainer)
}

#Preview("Group Detail") {
    GroupDetailView(group: PreviewHelper.shared.previewGroups[0])
        .modelContainer(PreviewHelper.shared.modelContainer)
}

#Preview("Create Group Sheet") {
    CreateGroupSheet(
        name: .constant("New Group"),
        selectedCards: Set(PreviewHelper.shared.previewCards.prefix(2)),
        onCreate: {}
    )
    .modelContainer(PreviewHelper.shared.modelContainer)
}
