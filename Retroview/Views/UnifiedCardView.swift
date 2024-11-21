//
//  UnifiedCardView.swift
//  Retroview
//
//  Created by Adam Schuster on 11/18/24.
//

#if os(macOS)
import AppKit
#else
import UIKit
#endif
import SwiftData
import SwiftUI

struct UnifiedCardView: View {
    @Bindable var card: CardSchemaV1.StereoCard
    @StateObject private var viewModel: StereoCardViewModel
    let style: ViewStyle
    
    enum ViewStyle {
        case grid
        case list
    }
    
    init(card: CardSchemaV1.StereoCard, style: ViewStyle = .grid) {
        self.card = card
        self.style = style
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
        Group {
            if style == .list {
                HStack(spacing: 16) {
                    StereoCardImageView(viewModel: viewModel, side: "front")
                        .frame(minWidth: 200, maxWidth: .infinity)
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    cardDetails
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    StereoCardImageView(viewModel: viewModel, side: "front")
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .shadow(radius: 4)
                    
                    cardDetails
                        .padding(.horizontal, 4)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(platformBackground)
    }
    
    private var cardDetails: some View {
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
    }
}

#Preview("Single Card") {
    CardPreviewContainer { card in
        UnifiedCardView(card: card)
    }
}
