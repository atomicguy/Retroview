//
//  CardThumbnailView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/15/24.
//

import QuickLook
import SwiftData
import SwiftUI

struct ThumbnailView: View {
    @Environment(\.imageLoader) private var imageLoader
    let card: CardSchemaV1.StereoCard
    
    @State private var image: CGImage?
    @State private var isLoading = false
    @State private var loadError = false
    @State private var aspectRatio: CGFloat = 2.0
    @State private var loadingTask: Task<Void, Never>?
    
    // Track visibility for priority loading
    @State private var isVisible = false

    var body: some View {
        Group {
            if let image {
                Image(decorative: image, scale: 1.0)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                placeholderView
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .aspectRatio(aspectRatio, contentMode: .fit)
        .onAppear {
            isVisible = true
            startLoadingImage()
        }
        .onDisappear {
            isVisible = false
            // Cancel if not needed now
            loadingTask?.cancel()
        }
    }
    
    private var placeholderView: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.gray.opacity(0.1))
            .overlay {
                if isLoading {
                    ProgressView()
                } else if loadError {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                } else {
                    Image(systemName: "photo")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }
            }
    }
    
    private func startLoadingImage() {
        guard loadingTask == nil, !isLoading, let imageLoader = imageLoader else { return }
        
        loadingTask = Task { @MainActor in
            // Skip if already loaded or loading
            guard image == nil, !isLoading else { return }
            
            isLoading = true
            defer { isLoading = false }
            
            do {
                if let loadedImage = try await imageLoader.loadImage(
                    for: card,
                    side: .front,
                    quality: .thumbnail
                ) {
                    // Only update if still visible
                    if isVisible {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            aspectRatio = CGFloat(loadedImage.width) / CGFloat(loadedImage.height)
                            image = loadedImage
                        }
                    }
                }
            } catch {
                if isVisible {
                    loadError = true
                }
            }
            
            loadingTask = nil
        }
    }
}

#Preview("Thumbnail View") {
    if let card = try? PreviewDataManager.shared.container().mainContext.fetch(
        FetchDescriptor<CardSchemaV1.StereoCard>()
    ).first {
        ThumbnailView(card: card)
            .withPreviewStore()
            .environment(\.imageLoader, CardImageLoader())
            .frame(width: 300, height: 200)
    } else {
        ContentUnavailableView("No Preview Card", systemImage: "photo")
            .withPreviewStore()
    }
}
