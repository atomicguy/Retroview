//
//  PreviewContainer.swift
//  Retroview
//
//  Created by Adam Schuster on 12/9/24.
//

import SwiftUI

struct PreviewContainer<Content: View>: View {
    let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        content()
            .modelContainer(for: CardSchemaV1.StereoCard.self, inMemory: true)
            .task {
                try? await PreviewDataManager.shared.populateData()
            }
    }
}
