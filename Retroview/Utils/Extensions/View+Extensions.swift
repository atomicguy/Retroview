//
//  View+Extensions.swift
//  Retroview
//
//  Created by Adam Schuster on 12/9/24.
//

import SwiftUI

extension View {
    func cardInteractive(
        card: CardSchemaV1.StereoCard,
        onSelect: ((CardSchemaV1.StereoCard) -> Void)? = nil
    ) -> some View {
        modifier(CardInteractionModifier(card: card, onSelect: onSelect))
    }
    
    func withCardTitle(_ title: String) -> some View {
        overlay(alignment: .bottom) {
            Text(title)
                .font(.headline)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
        }
    }
}

