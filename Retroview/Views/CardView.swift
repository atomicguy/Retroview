//
//  CardView.swift
//  Retroview
//
//  Created by Adam Schuster on 5/12/24.
//

import SwiftData
import SwiftUI
#if os(macOS)
import AppKit
#else
import UIKit
#endif

struct CardView: View {
    @Bindable var card: CardSchemaV1.StereoCard
    @StateObject private var viewModel: StereoCardViewModel

    init(card: CardSchemaV1.StereoCard) {
        self.card = card
        _viewModel = StateObject(wrappedValue: StereoCardViewModel(stereoCard: card))
    }

    var displayTitle: TitleSchemaV1.Title {
        card.titlePick ?? card.titles.first ?? TitleSchemaV1.Title(text: "Unknown")
    }
    
    var platformBackground: Color {
        #if os(macOS)
        Color(NSColor.windowBackgroundColor)
        #else
        Color(UIColor.systemBackground)
        #endif
    }

    var body: some View {
        HStack(spacing: 16) {
            StereoCardImageView(viewModel: viewModel, side: "front")
                .frame(minWidth: 200, maxWidth: .infinity)
                .frame(height: 200)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .shadow(radius: 4)

            VStack(alignment: .leading, spacing: 8) {
                Text(displayTitle.text)
                    .font(.headline)
                    .lineLimit(2)

                if !card.authors.isEmpty {
                    Text(card.authors.first?.name ?? "Unknown Author")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                if !card.dates.isEmpty {
                    Text(card.dates.first?.text ?? "Unknown Date")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(platformBackground)
    }
}

#Preview("Card View") {
    CardView(card: PreviewHelper.shared.previewCard)
        .modelContainer(PreviewHelper.shared.modelContainer)
        .frame(width: 600)
}
