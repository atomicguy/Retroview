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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
            
            if let imageId = side == .front ? card.imageFrontId : card.imageBackId {
                AsyncImage(
                    url: URL(string: "https://iiif-prod.nypl.org/index.php?id=\(imageId)&t=\(ImageQuality.thumbnail.rawValue)")
                ) { thumbnailPhase in
                    switch thumbnailPhase {
                    case .empty:
                        loadingPlaceholder
                    case .success(let thumbnail):
                        AsyncImage(
                            url: URL(string: "https://iiif-prod.nypl.org/index.php?id=\(imageId)&t=\(ImageQuality.high.rawValue)")
                        ) { fullPhase in
                            switch fullPhase {
                            case .success(let fullImage):
                                fullImage
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                    .transition(.opacity)
                            default:
                                thumbnail
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                            }
                        }
                    case .failure:
                        errorPlaceholder
                    @unknown default:
                        EmptyView()
                    }
                }
            }
        }
    }
    
    private var loadingPlaceholder: some View {
        Rectangle()
            .fill(.gray.opacity(0.1))
            .aspectRatio(2/1, contentMode: .fit)
            .overlay {
                ProgressView()
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var errorPlaceholder: some View {
        Rectangle()
            .fill(.gray.opacity(0.1))
            .aspectRatio(2/1, contentMode: .fit)
            .overlay {
                Label("Failed to load", systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.secondary)
            }
            .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
