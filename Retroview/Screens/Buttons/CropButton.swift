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
                .font(.title2)
                .foregroundStyle(.white)  // Add this line
                                .shadow(radius: 2)  // Add this line
        }
        .buttonStyle(.plain)
        .platformInteraction(
            InteractionConfig(
                showHoverEffects: true
            )
        )
        .help(showCrops ? "Hide Crops" : "Show Crops")
        .imageScale(.large) 
    }
}
