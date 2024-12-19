//
//  CardThumbnailView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/15/24.
//

import SwiftData
import SwiftUI

struct ThumbnailView: View {
    let card: CardSchemaV1.StereoCard
    var navigationEnabled = true
    
    @State private var imageManager: CardImageManager?
    @State private var loadingError = false
    @State private var isLoading = false
    
    var body: some View {
        Group {
            if navigationEnabled {
                NavigationLink(destination: CardDetailView(card: card)) {
                    thumbnailContent
                }
                .buttonStyle(.plain)
            } else {
                thumbnailContent
            }
        }
        .task {
            await loadImage()
        }
    }
    
    private var thumbnailContent: some View {
        ZStack {
            if let image = imageManager?.storedImage {
                Image(decorative: image, scale: 1.0)
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                placeholderView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .aspectRatio(2, contentMode: .fit)
    }
    
    private var placeholderView: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.gray.opacity(0.2))
            .overlay {
                if loadingError {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                } else if isLoading {
                    ProgressView()
                } else {
                    Image(systemName: "photo")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
            }
    }
    
    @MainActor
    private func loadImage() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        
        // Initialize image manager if needed
        if imageManager == nil {
            imageManager = CardImageManager(card: card, side: .front, quality: .thumbnail)
        }
        
        // Try loading from URL if not in storage
        if imageManager?.storedImage == nil, let url = imageManager?.imageURL {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                imageManager?.storeImageData(data)
            } catch {
                loadingError = true
            }
        }
    }
}
