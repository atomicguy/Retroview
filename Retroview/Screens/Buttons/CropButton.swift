//
//  CropButton.swift
//  Retroview
//
//  Created by Adam Schuster on 12/27/24.
//

import SwiftUI

struct CropButton: View {
    let card: CardSchemaV1.StereoCard
    @State private var showingCropOverlay = false
    
    var body: some View {
        Button {
            showingCropOverlay = true
        } label: {
            Image(systemName: "crop")
                .font(.title2)
        }
        .sheet(isPresented: $showingCropOverlay) {
            NavigationStack {
                CardCropOverlayView(card: card)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Done") {
                                showingCropOverlay = false
                            }
                        }
                    }
            }
            #if os(macOS)
            .frame(minWidth: 800, minHeight: 400)
            #else
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            #endif
        }
    }
}
