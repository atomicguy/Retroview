//
//  SharableCard.swift
//  Retroview
//
//  Created by Adam Schuster on 12/29/24.
//

import SwiftUI

struct ShareableCard: ViewModifier {
    let card: CardSchemaV1.StereoCard
    @State private var isSharePresented = false

    func body(content: Content) -> some View {
        content
            .contextMenu {
                if let data = card.spatialPhotoData {
                    ShareLink(
                        item: data,
                        preview: SharePreview(
                            card.titlePick?.text ?? "Stereo Card",
                            image: card.frontThumbnailData
                                ?? sfSymbolAsImageData
                        )
                    )
                }
            }
    }

    private var sfSymbolAsImageData: Data {
        let config = UIImage.SymbolConfiguration(
            pointSize: 100, weight: .regular)
        let symbolImage = UIImage(
            systemName: "photo.stack", withConfiguration: config)
        return symbolImage?.jpegData(compressionQuality: 0.8) ?? Data()
    }
}

extension View {
    func shareable(card: CardSchemaV1.StereoCard) -> some View {
        modifier(ShareableCard(card: card))
    }
}
#Preview {
    Text("Hello, World!").padding()
}