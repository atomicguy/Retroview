//
//  StyleStereoView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/1/24.
//

import SwiftData
import SwiftUI

#if os(visionOS)
struct StyleStereoView: View {
    let card: CardSchemaV1.StereoCard
    @Environment(\.dismiss) private var dismiss
    
    private var displayTitle: String {
        card.titlePick?.text ?? card.titles.first?.text ?? "Untitled"
    }
    
    private let stereoViewVerticalOffset: CGFloat = -100
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Main content
                StereoView(card: card)
                    .frame(maxWidth: .infinity, maxHeight: geometry.size.height * 0.85)
                    .padding(.top, geometry.size.height * 0.1)
                    .offset(y: stereoViewVerticalOffset)
                
                // Title ornament
                Text(displayTitle)
                    .font(.system(.title2, design: .serif))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal, 32)
                    .padding(.bottom, 16)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .ignoresSafeArea()
    }
}
#endif
