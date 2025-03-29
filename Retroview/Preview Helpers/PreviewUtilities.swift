//
//  PreviewUtilities.swift
//  Retroview
//
//  Created by Adam Schuster on 12/26/24.
//

import Foundation

import Foundation
import SwiftUI

enum PreviewUtilities {
    // Helper to detect if we're in a preview environment
    static var isPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
    
    // Get the bundle containing preview resources
    static var previewBundle: Bundle {
        #if DEBUG
        if let previewBundlePath = Bundle.main.path(forResource: "Preview Content", ofType: nil),
           let previewBundle = Bundle(path: previewBundlePath) {
            return previewBundle
        }
        #endif
        return Bundle.main
    }
    
    // Debug helper
    static func debugPreviewInfo() {
        print("Preview environment: \(isPreview)")
        print("Preview bundle path: \(previewBundle.bundlePath)")
        if let previewContent = previewBundle.url(forResource: "preview", withExtension: "store") {
            print("Preview store found at: \(previewContent.path)")
        } else {
            print("No preview.store found in bundle")
        }
    }
}
