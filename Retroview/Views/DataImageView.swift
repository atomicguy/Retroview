//
//  DataImageView.swift
//  Retroview
//
//  Created by Adam Schuster on 5/19/24.
//

import SwiftUI
import Foundation

struct DataImageView: View {
    var imageData: Data?
    
#if os(iOS) || os(tvOS) || os(visionOS)
    private func getImage() -> UIImage? {
        guard let data = imageData else { return nil }
        return UIImage(data: data)
    }
#elseif os(macOS)
    private func getImage() -> NSImage? {
        print("trying to load image")
        guard let data = imageData else { return nil }
        return NSImage(data: data)
    }
#endif
    
    var body: some View {
#if os(iOS) || os(tvOS) || os(visionOS)
        if let uiImage = getImage() {
            Image(uiImage: uiImage)
                .resizable()
                .scaledToFit()
        } else {
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
        }
#elseif os(macOS)
        if let nsImage = getImage() {
            Image(nsImage: nsImage)
                .resizable()
                .scaledToFit()
        } else {
            Image(systemName: "photo")
                .resizable()
                .scaledToFit()
        }
#endif
    }
}
