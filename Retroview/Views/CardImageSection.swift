//
//  CardImageSection.swift
//  Retroview
//
//  Created by Adam Schuster on 12/17/24.
//

import SwiftUI

struct CardImageSection: View {
    let card: CardSchemaV1.StereoCard
    let side: CardSide
    let title: String
    
    @State private var image: CGImage?
    @State private var isLoading = false
    @State private var error: Error?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Group {
                if let image {
                    Image(decorative: image, scale: 1.0)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.gray.opacity(0.1))
                        .aspectRatio(2/1, contentMode: .fit)
                        .overlay {
                            if isLoading {
                                ProgressView()
                            } else if error != nil {
                                Label("Failed to load", systemImage: "exclamationmark.triangle")
                                    .foregroundStyle(.secondary)
                            }
                        }
                }
            }
            .task(id: card.uuid) {
                await loadImage()
            }
            .refreshable {
                await loadImage()
            }
        }
    }
    
    private func loadImage() async {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        do {
            // First try thumbnail for quick loading
            image = try await card.loadImage(side: side, quality: .thumbnail)
            
            // Then load full quality
            image = try await card.loadImage(side: side, quality: .standard)
        } catch {
            self.error = error
        }
        
        isLoading = false
    }
}
