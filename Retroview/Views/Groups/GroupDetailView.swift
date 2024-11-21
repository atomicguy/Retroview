//
//  GroupDetailView.swift
//  Retroview
//
//  Created by Adam Schuster on 11/20/24.
//

import SwiftData
import SwiftUI

struct GroupDetailView: View {
    @Bindable var group: CardGroupSchemaV1.Group
    @StateObject private var groupManager = GroupManager()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            GroupHeader(group: group)

            // Cards Grid
            ScrollView {
                LazyVGrid(columns: [.init(.adaptive(minimum: 300))]) {
                    ForEach(group.cards) { card in
                        UnifiedCardView(card: card)
                            .contextMenu {
                                Button(role: .destructive) {
                                    groupManager.removeCards(
                                        [card], from: group)
                                } label: {
                                    Label(
                                        "Remove from Group",
                                        systemImage: "minus.circle")
                                }
                            }
                    }
                }
                .padding()
            }
        }
        .padding()
        .toolbar {
            Menu {
                Button(role: .destructive) {
                    groupManager.removeCards(group.cards, from: group)
                } label: {
                    Label("Remove All Cards", systemImage: "trash")
                }

                Button {
                    NotificationCenter.default.post(
                        name: .exportGroupRequested,
                        object: nil)
                } label: {
                    Label("Export Group...", systemImage: "square.and.arrow.up")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
            }
        }
    }
}

// MARK: - Supporting Views

private struct GroupHeader: View {
    let group: CardGroupSchemaV1.Group

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(group.name)
                .font(.title)

            Text("Created \(group.createdAt.formatted())")
                .foregroundStyle(.secondary)

            Text("\(group.cards.count) cards")
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Preview Support

#Preview {
    NavigationStack {
        GroupDetailView(group: PreviewHelper.shared.previewGroups[0])
            .modelContainer(PreviewHelper.shared.modelContainer)
    }
}
