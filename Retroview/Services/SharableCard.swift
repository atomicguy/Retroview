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
                            image: sfSymbolAsImageData
                        )
                    )
                }
            }
    }

    private var sfSymbolAsImageData: Image {
        #if os(macOS)
            if let nsImage = NSImage(
                systemSymbolName: "photo.stack",
                accessibilityDescription: "Photo Stack"
            ) {
                return Image(nsImage: nsImage)
            }
        #else
            if let uiImage = UIImage(
                systemName: "photo.stack",
                withConfiguration: UIImage.SymbolConfiguration(
                    pointSize: 100, weight: .regular)
            ) {
                return Image(uiImage: uiImage)
            }
        #endif
        return Image(systemName: "photo.stack")  // Fallback
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
