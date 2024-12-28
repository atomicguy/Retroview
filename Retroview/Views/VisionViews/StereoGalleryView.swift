//
//  StereoGalleryView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/27/24.
//

import SwiftUI
import SwiftData

#if os(visionOS)
import SwiftUI
import SwiftData

struct StereoGalleryView: View {
    let cards: [CardSchemaV1.StereoCard]
    @Environment(\.dismiss) private var dismiss
    @Environment(\.imageLoader) private var imageLoader
    
    @State private var selectedIndex: Int
    @State private var currentCardID: UUID
    @GestureState private var dragOffset: CGFloat = 0
    
    // Track preloaded images
    @State private var preloadedImages: [UUID: CGImage] = [:]
    
    init(cards: [CardSchemaV1.StereoCard], initialCard: CardSchemaV1.StereoCard? = nil) {
        self.cards = cards
        let index = initialCard.flatMap { cards.firstIndex(of: $0) } ?? 0
        _selectedIndex = State(initialValue: index)
        _currentCardID = State(initialValue: cards[index].uuid)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Main stereo view container - floating section
            mainStereoSection
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.clear)
            
            // Visual separation
            Spacer(minLength: 32)
            
            // Thumbnail strip - glass texture section
            thumbnailSection
                .frame(height: 80)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal)
        }
        .task {
            await preloadAdjacentImages()
        }
        .onChange(of: selectedIndex) {
            Task {
                await preloadAdjacentImages()
            }
        }
    }
    
    private var mainStereoSection: some View {
        ZStack {
            // Stereo view
            StereoView(card: cards[selectedIndex])
                .id(currentCardID)
                .contentTransition(.opacity)
                .overlay(alignment: .topLeading) {
                    dismissButton
                }
                .background(.clear)
            
            // Gesture areas
            HStack {
                swipeArea(edge: .leading)
                swipeArea(edge: .trailing)
            }
            
            // Navigation buttons
            HStack {
                if selectedIndex > 0 {
                    navigationButton(direction: .previous)
                }
                Spacer()
                if selectedIndex < cards.count - 1 {
                    navigationButton(direction: .next)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var dismissButton: some View {
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
    
    private var thumbnailSection: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: 12) {
                    ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                        ThumbnailView(card: card)
                            .frame(width: 120, height: 60)
                            .overlay {
                                if index == selectedIndex {
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(.white, lineWidth: 2)
                                }
                            }
                            .id(index)
                            .onTapGesture {
                                withAnimation {
                                    selectedIndex = index
                                    currentCardID = card.uuid
                                }
                            }
                    }
                }
                .padding(.horizontal)
            }
            .onChange(of: selectedIndex) { _, newValue in
                withAnimation {
                    proxy.scrollTo(newValue, anchor: .center)
                }
            }
        }
    }
    
    private func swipeArea(edge: HorizontalEdge) -> some View {
        Rectangle()
            .fill(.clear)
            .contentShape(Rectangle())
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation.width
                    }
                    .onEnded { value in
                        handleSwipe(value.translation.width, from: edge)
                    }
            )
            .frame(maxWidth: .infinity)
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
    
    private func handleSwipe(_ translation: CGFloat, from edge: HorizontalEdge) {
        let threshold: CGFloat = 50
        let canNavigateLeft = selectedIndex > 0
        let canNavigateRight = selectedIndex < cards.count - 1
        
        withAnimation {
            if translation > threshold && canNavigateLeft && edge == .leading {
                selectedIndex -= 1
                currentCardID = cards[selectedIndex].uuid
            } else if translation < -threshold && canNavigateRight && edge == .trailing {
                selectedIndex += 1
                currentCardID = cards[selectedIndex].uuid
            }
        }
    }
    
    private func preloadAdjacentImages() async {
        guard let imageLoader else { return }
        
        // Define the range of indices to preload
        let preloadRange = max(0, selectedIndex - 1)...min(cards.count - 1, selectedIndex + 1)
        
        await withTaskGroup(of: Void.self) { group in
            for index in preloadRange {
                let card = cards[index]
                // Only preload if we haven't already
                if preloadedImages[card.uuid] == nil {
                    group.addTask {
                        if let image = try? await imageLoader.loadImage(
                            for: card,
                            side: .front,
                            quality: .high
                        ) {
                            await MainActor.run {
                                preloadedImages[card.uuid] = image
                            }
                        }
                    }
                }
            }
        }
    }
}

private enum NavigationDirection {
    case next
    case previous
    
    var systemImage: String {
        switch self {
        case .previous: "chevron.left"
        case .next: "chevron.right"
        }
    }
}

#Preview("Stereo Gallery - Multiple Cards") {
    let container = try! PreviewDataManager.shared.container()
    let descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
    let cards = try! container.mainContext.fetch(descriptor)
    
    return NavigationStack {
        StereoGalleryView(cards: cards)
            .withPreviewStore()
            .environment(\.imageLoader, CardImageLoader())
    }
}

#Preview("Stereo Gallery - Card with Images") {
    guard let card = PreviewDataManager.shared.singleCard({ card in
        card.imageFrontId != nil && card.leftCrop != nil
    }) else {
        return Text("No suitable preview card found")
    }
    
    return NavigationStack {
        StereoGalleryView(cards: [card])
            .withPreviewStore()
            .environment(\.imageLoader, CardImageLoader())
    }
}
#endif
