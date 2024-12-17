//
//  ImageStore.swift
//  Retroview
//
//  Created by Adam Schuster on 12/15/24.
//

import SwiftData
import Foundation
import CoreGraphics

// MARK: - Image Store
@Model
final class ImageStore {
    var imageId: String
    var side: String
    
    @Attribute(.externalStorage)
    private var imageData: Data?
    
    @Transient
    private var _lastAccessed: Date = Date()
    
    var lastAccessed: Date {
        get { _lastAccessed }
        set { _lastAccessed = newValue }
    }
    
    var isDownloaded: Bool { imageData != nil }
    
    init(imageId: String = "", side: String, imageData: Data? = nil) {
        self.imageId = imageId
        self.side = side
        self.imageData = imageData
        self.lastAccessed = Date()
    }
    
    func setImage(_ data: Data) {
        imageData = data
        lastAccessed = Date()
    }
    
    func getImageData() -> Data? {
        lastAccessed = Date()
        return imageData
    }
}
