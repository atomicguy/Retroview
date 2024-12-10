//
//  StereoControlsView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/9/24.
//

#if os(visionOS)
import SwiftUI

struct StereoControlsView: View {
    let onClose: () -> Void
    @Binding var selectedCard: StereoCard
    let cards: [StereoCard]
    @Binding var displayMode: DisplayMode
    
    enum DisplayMode {
        case stereo
        case sideBySide
        case anaglyph
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Top Bar
            HStack {
                // Close Button
                Button(action: onClose) {
                    Label("Close", systemImage: "xmark.circle.fill")
                        .font(.title2)
                }
                
                Spacer()
                
                // View Mode Picker
                Picker("Display Mode", selection: $displayMode) {
                    Label("Stereo", systemImage: "rectangle.3.group")
                        .tag(DisplayMode.stereo)
                    Label("Side by Side", systemImage: "rectangle.split.2x1")
                        .tag(DisplayMode.sideBySide)
                    Label("Anaglyph", systemImage: "glasses")
                        .tag(DisplayMode.anaglyph)
                }
                .pickerStyle(.segmented)
                .frame(width: 300)
                
                Spacer()
                
                // Info Button
                Button {
                    // Show metadata
                } label: {
                    Label("Info", systemImage: "info.circle")
                        .font(.title2)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            
            Spacer()
            
            // Bottom Bar with Thumbnails
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(cards) { card in
                        ThumbnailView(card: card)
                            .frame(width: 120, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(card.id == selectedCard.id ? Color.accentColor : Color.clear,
                                          lineWidth: 2)
                            )
                            .onTapGesture {
                                withAnimation {
                                    selectedCard = card
                                }
                            }
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 80)
            .background(.ultraThinMaterial)
        }
    }
}

#if DEBUG
#Preview("Stereo Controls") {
    let descriptor = FetchDescriptor<StereoCard>()
    let container = try! PreviewDataManager.shared.container()
    let cards = try! container.mainContext.fetch(descriptor)
    
    return StereoControlsView(
        onClose: {},
        selectedCard: .constant(cards[0]),
        cards: cards,
        displayMode: .constant(.stereo)
    )
    .withPreviewData()
}
#endif
#endif
