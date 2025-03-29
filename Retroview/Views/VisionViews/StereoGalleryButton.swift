//
//  StereoGalleryButton.swift
//  Retroview
//
//  Created by Adam Schuster on 12/27/24.
//

#if os(visionOS)
    import SwiftUI

    struct StereoGalleryButton: View {
        let cards: [CardSchemaV1.StereoCard]
        let selectedCard: CardSchemaV1.StereoCard?
        @State private var showingGallery = false
        @State private var isLoading = false

        var body: some View {
            Button {
                Task {
                    isLoading = true
                    showingGallery = true
                    isLoading = false
                }
            } label: {
                if isLoading {
                    ProgressView()
                } else {
                    Label("View in Stereo", systemImage: "view.3d")
                }
            }
            .disabled(isLoading)
            .disabled(isLoading)
            .sheet(isPresented: $showingGallery) {
                NavigationStack {
                    StereoGalleryView(cards: cards, initialCard: selectedCard)
                        .frame(width: 400, height: 300)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Done") {
                                    showingGallery = false
                                }
                            }
                        }
                }
            }
        }
    }
#endif
