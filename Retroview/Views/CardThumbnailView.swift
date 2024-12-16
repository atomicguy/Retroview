//
//  CardThumbnailView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/15/24.
//

import SwiftData
import SwiftUI

struct CardThumbnail: View {
    let card: CardSchemaV1.StereoCard
    @State private var image: CGImage?
    @State private var loadingError = false
    
    var body: some View {
        NavigationLink(destination: CardDetailView(card: card)) {
            ZStack {
                if let image {
                    Image(decorative: image, scale: 1.0)
                        .resizable()
                        .scaledToFit()
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    placeholderView
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .aspectRatio(2, contentMode: .fit)
        }
        .buttonStyle(.plain)
        .task(id: card.uuid) {
            do {
                image = try await card.loadThumbnail(for: .front)
            } catch {
                loadingError = true
            }
        }
    }
    
    @ViewBuilder
    private var placeholderView: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(.gray.opacity(0.2))
            .overlay {
                if loadingError {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                } else if card.imageFrontId != nil {
                    ProgressView()
                } else {
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                }
            }
    }
}
