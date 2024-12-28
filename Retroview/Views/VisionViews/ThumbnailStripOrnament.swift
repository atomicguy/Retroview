//
//  ThumbnailStripOrnament.swift
//  Retroview
//
//  Created by Adam Schuster on 12/27/24.
//

import SwiftUI

#if os(visionOS)
struct ThumbnailStripOrnament: View {
    let cards: [CardSchemaV1.StereoCard]
    @State private var selectedIndex: Int
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    
    init(cards: [CardSchemaV1.StereoCard], selectedIndex: Int) {
        self.cards = cards
        _selectedIndex = State(initialValue: selectedIndex)
    }
    
    var body: some View {
        ThumbnailGalleryStrip(cards: cards, selectedIndex: $selectedIndex)
            .onChange(of: selectedIndex) { _, newValue in
                // Close and reopen main window to show new card
                dismissWindow(id: "stereo-gallery")
                openWindow(id: "stereo-gallery")
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(.thinMaterial)
    }
}
#endif
