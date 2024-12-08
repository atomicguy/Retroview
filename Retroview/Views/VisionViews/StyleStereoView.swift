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
    @ObservedObject var viewModel: StereoCardViewModel
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

//#Preview("Style Stereo View - Standard") {
//    let descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
//    let container = try! PreviewDataManager.shared.container()
//    let card = try! container.mainContext.fetch(descriptor).first!
//    
//    StyleStereoView(card: card, viewModel: StereoCardViewModel)
//        .withPreviewData()
//        .frame(width: 800, height: 600)
//}
//
//#Preview("Style Stereo View - Full Screen") {
//    let descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
//    let container = try! PreviewDataManager.shared.container()
//    let card = try! container.mainContext.fetch(descriptor).first!
//    
//    StyleStereoView(
//        card: card,
//        viewModel: .fullScreen
//    )
//    .withPreviewData()
//    .frame(width: 1200, height: 800)
//}
//
//#Preview("Style Stereo View - Compact") {
//    let descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
//    let container = try! PreviewDataManager.shared.container()
//    let card = try! container.mainContext.fetch(descriptor).first!
//    
//    StyleStereoView(
//        card: card,
//        viewModel: .compact
//    )
//    .withPreviewData()
//    .frame(width: 400, height: 300)
//}
//
//#Preview("Style Stereo View - Viewer Mode") {
//    let descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
//    let container = try! PreviewDataManager.shared.container()
//    let card = try! container.mainContext.fetch(descriptor).first!
//    
//    StyleStereoView(
//        card: card,
//        viewModel: .viewer
//    )
//    .withPreviewData()
//    .frame(width: 800, height: 600)
//}

#endif
