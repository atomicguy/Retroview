//
//  URLImageView.swift
//  Retroview
//
//  Created by Adam Schuster on 5/27/24.
//

import Foundation
import SwiftUI

struct URLImageView: View {
    @StateObject private var loader = ImageLoader()
    let url: URL?
    let side: String
    let card: CardSchemaV1.StereoCard
    
    var body: some View {
        Group {
            if let image = loader.image {
                #if os(iOS) || os(tvOS)
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                #elseif os(macOS)
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
                #endif
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
            }
        }
        .onAppear {
            if let url = url {
                loader.loadImage(from: url, for: side, in: card)
            }
        }
    }
}
