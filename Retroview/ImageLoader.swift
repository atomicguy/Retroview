//
//  ImageLoader.swift
//  Retroview
//
//  Created by Adam Schuster on 5/27/24.
//

import Foundation
import SwiftUI
import Combine

class ImageLoader: ObservableObject {
    @Published var image: PlatformImage? = nil
    
    private var cancellable: AnyCancellable?
    
    func loadImage(from url: URL, for side: String, in card: CardSchemaV1.StereoCard) {
        #if os(iOS) || os(tvOS) || os(visionOS)
        if side == "front", let cachedData = card.imageFront, let cachedImage = UIImage(data: cachedData) {
            self.image = cachedImage
            return
        }
        
        if side == "back", let cachedData = card.imageBack, let cachedImage = UIImage(data: cachedData) {
            self.image = cachedImage
            return
        }
        #elseif os(macOS)
        if side == "front", let cachedData = card.imageFront, let cachedImage = NSImage(data: cachedData) {
            self.image = cachedImage
            return
        }
        
        if side == "back", let cachedData = card.imageBack, let cachedImage = NSImage(data: cachedData) {
            self.image = cachedImage
            return
        }
        #endif
        
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { PlatformImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] downloadedImage in
                guard let self = self, let downloadedImage = downloadedImage else { return }
                
                if side == "front" {
                    card.imageFront = downloadedImage.dataRepresentation()
                } else if side == "back" {
                    card.imageBack = downloadedImage.dataRepresentation()
                }
                
                self.image = downloadedImage
            }
    }
    
    deinit {
        cancellable?.cancel()
    }
}

#if os(iOS) || os(tvOS) || os(visionOS)
import UIKit
typealias PlatformImage = UIImage
extension UIImage {
    func dataRepresentation() -> Data? {
        return self.pngData()
    }
}
#elseif os(macOS)
import AppKit
typealias PlatformImage = NSImage
extension NSImage {
    func dataRepresentation() -> Data? {
        return self.tiffRepresentation
    }
}
#endif

