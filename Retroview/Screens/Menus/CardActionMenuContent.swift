//
//  CardActionMenuContent.swift
//  Retroview
//
//  Created by Adam Schuster on 1/3/25.
//

import SwiftUI

struct CardActionMenuContent: View {
    let card: CardSchemaV1.StereoCard
    let onShare: () -> Void
    let onViewInSpace: () -> Void
    let onAddToCollection: () -> Void
    let onReloadImages: () -> Void

    var body: some View {
        VStack(spacing: 8) {
            actionButton(
                icon: "square.and.arrow.up", text: "Share Spatial Card...",
                action: onShare)
            actionButton(
                icon: "view.3d", text: "View in Space", action: onViewInSpace)
            actionButton(
                icon: "folder.badge.plus", text: "Add to Collection",
                action: onAddToCollection)
            Divider()
            actionButton(
                icon: "arrow.clockwise", text: "Reload Images",
                action: onReloadImages)
        }
        .padding()
        .cornerRadius(12)
        .shadow(radius: 5)
    }

    // MARK: - Action Button Helper

    private func actionButton(
        icon: String, text: String, action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {

            HStack {
                #if os(visionOS)
                    Text(text)
                    Spacer()
                    Image(systemName: icon)
                #else
                    Image(systemName: icon)
                    Text(text)
                    Spacer()  // Ensures alignment to the left
                #endif
            }

            .padding()
            .frame(maxWidth: .infinity)  // Ensures equal width
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    CardPreviewContainer { card in
        CardActionMenuContent(
            card: card,
            onShare: {},
            onViewInSpace: {},
            onAddToCollection: {},
            onReloadImages: {}
        )
    }
}
