//
//  FullScreenStereoView.swift
//  Retroview
//
//  Created by Adam Schuster on 10/20/24.
//

import RealityKit
import SwiftUI

struct FullScreenStereoView: View {
    let card: CardSchemaV1.StereoCard
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Color.black.edgesIgnoringSafeArea(.all)

                // Stereo content
                StereoView(card: card)
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.height * 0.8
                    )
                    .position(
                        x: geometry.size.width / 2,
                        y: geometry.size.height / 2
                    )

                // Close button and title overlay
                VStack {
                    HStack {
                        if let title = card.titlePick?.text {
                            Text(title)
                                .font(.title)
                                .foregroundColor(.white)
                                .padding()
                        }
                        Spacer()
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.white)
                                .padding()
                        }
                    }
                    .background(Color.black.opacity(0.5))
                    Spacer()
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}
