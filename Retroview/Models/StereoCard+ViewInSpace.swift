//
//  StereoCard+ViewInSpace.swift
//  Retroview
//
//  Created by Adam Schuster on 1/5/25.
//

import SwiftUI
import QuickLook

#if os(visionOS)
extension CardSchemaV1.StereoCard {
    func viewInSpace(
        onStateChange: ((Bool) -> Void)? = nil
    ) async {
        @Environment(\.imageLoader) var imageLoader

        guard let loader = imageLoader else { return }

        onStateChange?(true)
        defer { onStateChange?(false) }

        do {
            guard let _ = try await loader.loadImage(
                for: self,
                side: .front,
                quality: .ultra
            ) else { return }

            let _ = try await PreviewApplication.openCards(
                [self],
                selectedCard: self,
                imageLoader: loader
            )
        } catch {
            print("Failed to open card in space: \(error)")
        }
    }
}
#endif
