//
//  InteractionModifier.swift
//  Retroview
//
//  Created by Adam Schuster on 12/9/24.
//

import SwiftUI

struct CardInteractionModifier: ViewModifier {
    let card: CardSchemaV1.StereoCard
    let onSelect: ((CardSchemaV1.StereoCard) -> Void)?
    
    @Environment(\.modelContext) private var modelContext
    @State private var showingCollectionSheet = false
    
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                onSelect?(card)
            }
            .contextMenu {
                CollectionMenu(card: card)
            }
            .sheet(isPresented: $showingCollectionSheet) {
                AddToCollectionSheet(card: card)
            }
    }
}
