//
//  StereoGalleryWindow.swift
//  Retroview
//
//  Created by Adam Schuster on 12/27/24.
//

import SwiftUI
import SwiftData

#if os(visionOS)
struct StereoGalleryWindow: Scene {
    let cards: [CardSchemaV1.StereoCard]
    let initialCardIndex: Int
    
    init(cards: [CardSchemaV1.StereoCard], initialCard: CardSchemaV1.StereoCard? = nil) {
        self.cards = cards
        self.initialCardIndex = initialCard.flatMap { cards.firstIndex(of: $0) } ?? 0
    }
    
    var body: some Scene {
        WindowGroup(id: "stereo-gallery") {
            StereoGalleryContent(
                cards: cards,
                initialIndex: initialCardIndex
            )
        }
        .windowResizability(.contentSize)
        
        WindowGroup(id: "thumbnail-strip") {
            ThumbnailStripOrnament(
                cards: cards,
                selectedIndex: initialCardIndex
            )
        }
        .defaultSize(width: 600, height: 100)
        .windowResizability(.contentSize)
    }
}

private struct StereoGalleryContent: View {
    let cards: [CardSchemaV1.StereoCard]
    @Environment(\.dismiss) private var dismiss
    @State private var selectedIndex: Int
    @State private var currentCardID: UUID
    
    init(cards: [CardSchemaV1.StereoCard], initialIndex: Int) {
        self.cards = cards
        _selectedIndex = State(initialValue: initialIndex)
        _currentCardID = State(initialValue: cards[initialIndex].uuid)
    }
    
    var body: some View {
        StereoView(card: cards[selectedIndex])
            .id(currentCardID)
            .overlay(alignment: .topLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title)
                        .foregroundStyle(.white)
                        .padding()
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .padding()
            }
            .overlay(alignment: .trailing) {
                if cards.count > 1 {
                    VStack {
                        if selectedIndex > 0 {
                            navigationButton(direction: .previous)
                        }
                        Spacer()
                        if selectedIndex < cards.count - 1 {
                            navigationButton(direction: .next)
                        }
                    }
                    .padding()
                }
            }
    }
    
    private func navigationButton(direction: NavigationDirection) -> some View {
        Button {
            withAnimation {
                switch direction {
                case .previous:
                    if selectedIndex > 0 {
                        selectedIndex -= 1
                        currentCardID = cards[selectedIndex].uuid
                    }
                case .next:
                    if selectedIndex < cards.count - 1 {
                        selectedIndex += 1
                        currentCardID = cards[selectedIndex].uuid
                    }
                }
            }
        } label: {
            Image(systemName: direction.systemImage)
                .font(.title)
                .foregroundStyle(.white)
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
    }
}

private enum NavigationDirection {
    case next
    case previous
    
    var systemImage: String {
        switch self {
        case .previous: "chevron.up"
        case .next: "chevron.down"
        }
    }
}
#endif
