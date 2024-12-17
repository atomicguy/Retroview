//
//  ThumbnailView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/1/24.
//

import SwiftData
import SwiftUI


struct ThumbnailView: View {
    let card: CardSchemaV1.StereoCard
    @State private var frontImage: CGImage?
    
    var body: some View {
        ZStack {
            if let image = frontImage {
                Image(decorative: image, scale: 1.0)
                    .resizable()
                    .scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                ProgressView()
            }
        }
        .task {
            do {
                if let frontId = card.imageFrontId {
                    frontImage = try await ImageServiceFactory.shared.getService().loadThumbnail(
                        id: frontId, side: .front, maxSize: 400
                    )
                }
            } catch {
                print("Error loading thumbnail: \(error)")
            }
        }
    }
}
