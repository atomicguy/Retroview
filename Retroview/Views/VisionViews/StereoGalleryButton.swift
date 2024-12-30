//
//  StereoGalleryButton.swift
//  Retroview
//
//  Created by Adam Schuster on 12/27/24.
//

import SwiftUI

struct StereoGalleryButton: View {
    let cards: [CardSchemaV1.StereoCard]
    let selectedCard: CardSchemaV1.StereoCard?
    @State private var showingGallery = false

    var body: some View {
        Button {
            showingGallery = true
        } label: {
            Label("View in Stereo", systemImage: "view.3d")
        }
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
