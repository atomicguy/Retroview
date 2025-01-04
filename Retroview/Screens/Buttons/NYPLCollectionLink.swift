//
//  NYPLCollectionLink.swift
//  Retroview
//
//  Created by Adam Schuster on 12/31/24.
//

import SwiftUI

struct NYPLCollectionLink: View {
    let cardUUID: UUID

    private var url: URL {
        URL(
            string:
                "https://digitalcollections.nypl.org/items/\(cardUUID.uuidString.lowercased())"
        )!
    }

    var body: some View {
        Link(destination: url) {
            Label(
                "New York Public Library Digital Collections",
                systemImage: "building.columns"
            )
            .font(.system(.body, design: .serif))
            .foregroundStyle(.secondary)
        }
        .buttonStyle(.plain)
        .platformInteraction(
            InteractionConfig(
                showHoverEffects: true
            )
        )
        #if os(macOS)
            .onHover { hovering in
                if hovering {
                    NSCursor.pointingHand.push()
                } else {
                    NSCursor.pop()
                }
            }
        #endif
    }
}

#Preview {
    NYPLCollectionLink(cardUUID: UUID())
        .padding()
}
