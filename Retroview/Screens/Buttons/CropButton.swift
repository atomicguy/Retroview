//
//  CropButton.swift
//  Retroview
//
//  Created by Adam Schuster on 12/27/24.
//

import SwiftUI

struct CropButton: View {
    @Binding var showCrops: Bool

    var body: some View {
        Button {
            showCrops.toggle()
        } label: {
            Image(systemName: showCrops ? "rectangle" : "rectangle.split.2x1")
                .overlayButtonStyle(opacity: 1.0)
        }
        .buttonStyle(.plain)
        .platformInteraction(
            InteractionConfig(
                showHoverEffects: true
            )
        )
        .help(showCrops ? "Crops Visible" : "Crops Hidden")
    }
}
