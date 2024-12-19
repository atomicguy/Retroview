//
//  AsyncImageLoadingView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/18/24.
//

import SwiftUI

struct AsyncImageLoadingView: View {
    let card: CardSchemaV1.StereoCard
    let side: CardSide
    let quality: ImageQuality
    
    @State private var image: CGImage?
    @State private var isLoading = false
    @State private var error: Error?
    
    var body: some View {
        Group {
            if let image {
                Image(decorative: image, scale: 1.0)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                placeholderView
            }
        }
        .task(id: "\(card.uuid)-\(side)-\(quality.rawValue)") {
            await loadImage()
        }
    }
    
    private var placeholderView: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.gray.opacity(0.1))
            .aspectRatio(2/1, contentMode: .fit)
            .overlay {
                Group {
                    if isLoading {
                        ProgressView()
                    } else if error != nil {
                        Label("Failed to load", systemImage: "exclamationmark.triangle")
                            .foregroundStyle(.secondary)
                    }
                }
            }
    }
    
    private func loadImage() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            // First try loading a cached thumbnail for immediate display
            if quality != .thumbnail {
                if let thumbnailImage = try await card.loadImage(side: side, quality: .thumbnail) {
                    image = thumbnailImage
                }
            }
            
            // Then load the requested quality
            if let finalImage = try await card.loadImage(side: side, quality: quality) {
                withAnimation {
                    image = finalImage
                }
            }
        } catch {
            self.error = error
        }
    }
}
