//
//  StereoPreviewItem.swift
//  Retroview
//
//  Created by Adam Schuster on 12/29/24.
//

import QuickLook

// Convenience extension for creating preview items from cards
extension CardSchemaV1.StereoCard {
    func asPreviewItem(url: URL) -> PreviewItem {
            PreviewItem(url: url, displayName: titlePick?.text ?? "Untitled Card")
        }
}
