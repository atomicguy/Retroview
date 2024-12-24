//
//  PlatformFileHandler.swift
//  Retroview
//
//  Created by Adam Schuster on 12/14/24.
//

import SwiftUI
import UniformTypeIdentifiers

#if os(macOS)
struct PlatformFileHandler {
    static func exportFile(data: Data, defaultName: String) async throws -> URL? {
        // Run the panel on the main thread using MainActor
        let url = await MainActor.run { () -> URL? in
            let panel = NSSavePanel()
            panel.nameFieldStringValue = defaultName
            
            guard panel.runModal() == .OK else {
                return nil
            }
            
            return panel.url
        }
        
        guard let url else { return nil }
        
        // Write data to the selected URL
        try data.write(to: url, options: .atomic)
        return url
    }
    
    static func importFile() async throws -> URL? {
        // Run the panel on the main thread using MainActor
        await MainActor.run { () -> URL? in
            let panel = NSOpenPanel()
            panel.allowsMultipleSelection = false
            
            guard panel.runModal() == .OK else {
                return nil
            }
            
            return panel.url
        }
    }
}
#else
@MainActor
struct PlatformFileHandler {
    static func exportFile(data: Data, defaultName: String) async throws -> URL? {
        // Create a temporary file URL in the app's temporary directory
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(defaultName)
        
        // Write the data to the temporary file
        try data.write(to: fileURL, options: .atomic)
        
        return fileURL
    }
    
    static func importFile() async throws -> URL? {
        return try await withCheckedThrowingContinuation { continuation in
            Task { @MainActor in
                let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.retroviewStore])
                let delegate = FilePickerDelegate(continuation: continuation)
                picker.delegate = delegate
                
                // Store delegate reference to prevent deallocation
                objc_setAssociatedObject(picker, "delegateKey", delegate, .OBJC_ASSOCIATION_RETAIN)
                
                // Present picker on the main thread
                if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   let controller = scene.windows.first?.rootViewController {
                    controller.present(picker, animated: true)
                } else {
                    continuation.resume(throwing: FileHandlerError.noPresentingViewController)
                }
            }
        }
    }
}

// Updated delegate to be self-contained and MainActor-isolated
@MainActor
private class FilePickerDelegate: NSObject, UIDocumentPickerDelegate {
    private let continuation: CheckedContinuation<URL?, Error>
    
    init(continuation: CheckedContinuation<URL?, Error>) {
        self.continuation = continuation
        super.init()
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        continuation.resume(returning: urls.first)
        cleanupDelegate(for: controller)
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        continuation.resume(returning: nil)
        cleanupDelegate(for: controller)
    }
    
    private func cleanupDelegate(for controller: UIDocumentPickerViewController) {
        objc_setAssociatedObject(controller, "delegateKey", nil, .OBJC_ASSOCIATION_RETAIN)
    }
}

enum FileHandlerError: LocalizedError {
    case noPresentingViewController
    
    var errorDescription: String? {
        switch self {
        case .noPresentingViewController:
            return "Could not find a view controller to present the file picker"
        }
    }
}
#endif
