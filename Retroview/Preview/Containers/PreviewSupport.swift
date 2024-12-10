//
//  PreviewSupport.swift
//  Retroview
//
//  Created by Adam Schuster on 12/9/24.
//

import SwiftUI

extension View {
    func withPreviewData() -> some View {
        modifier(PreviewDataModifier())
    }
}

struct PreviewDataModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .modelContainer(for: CardSchemaV1.StereoCard.self, inMemory: true)
            .task {
                try? await PreviewDataManager.shared.populateData()
            }
    }
}
