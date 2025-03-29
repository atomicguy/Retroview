//
//  StackThumbnailGenerator.swift
//  Retroview
//
//  Created by Adam Schuster on 1/19/25.
//

import SwiftData
import SwiftUI

struct StackThumbnailGenerator {
    static let maxStackedCards = 5

    @MainActor
    static func generateThumbnailData(
        for item: StackDisplayable,
        size: CGSize = CGSize(width: 300, height: 300)
    ) async throws -> Data {
        let view = StackThumbnailView(item: item)
            .frame(width: size.width, height: size.height)

        let renderer = ImageRenderer(content: view)
        renderer.scale = 2.0  // For retina quality

        #if os(macOS)
            guard let nsImage = renderer.nsImage,
                let thumbnailData = nsImage.tiffRepresentation(
                    using: .jpeg, factor: 0.8)
            else {
                throw ThumbnailError.renderingFailed
            }
            return thumbnailData
        #else
            guard let uiImage = renderer.uiImage,
                let thumbnailData = uiImage.jpegData(compressionQuality: 0.8)
            else {
                throw ThumbnailError.renderingFailed
            }
            return thumbnailData
        #endif
    }

    enum ThumbnailError: Error {
        case renderingFailed
    }
}
