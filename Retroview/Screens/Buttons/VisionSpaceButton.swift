//
//  VisionSpaceButton.swift
//  Retroview
//
//  Created by Adam Schuster on 1/11/25.
//

import SwiftUI

#if os(visionOS)
    struct VisionSpaceButton: View {
        @Environment(\.imageLoader) private var imageLoader
        let card: CardSchemaV1.StereoCard
        @State private var isLoading = false

        var body: some View {
            Button {
                Task {
                    await viewInSpace()
                }
            } label: {
                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                } else {
                    Label("View in Space", systemImage: "view.3d")
                }
            }
            .disabled(isLoading)
        }

        private func viewInSpace() async {
            guard !isLoading, let imageLoader = imageLoader else { return }
            isLoading = true

            await card.viewInSpace(
                imageLoader: imageLoader,
                onStateChange: { loading in
                    Task { @MainActor in
                        isLoading = loading
                    }
                }
            )
        }
    }
#endif
