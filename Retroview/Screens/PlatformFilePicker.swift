//
//  PlatformFilePicker.swift
//  Retroview
//
//  Created by Adam Schuster on 12/22/24.
//

import SwiftUI
import UniformTypeIdentifiers

protocol PlatformFilePicking {
    func pickFolders(
        allowMultiple: Bool,
        message: String,
        completion: @escaping ([URL]) -> Void
    )

    func pickFiles(
        allowMultiple: Bool,
        message: String,
        allowedContentTypes: [UTType]?,
        completion: @escaping ([URL]) -> Void
    )
}

#if os(macOS)
    struct MacPlatformFilePicker: PlatformFilePicking {
        func pickFolders(
            allowMultiple: Bool,
            message: String,
            completion: @escaping ([URL]) -> Void
        ) {
            let panel = NSOpenPanel()
            panel.allowsMultipleSelection = allowMultiple
            panel.canChooseDirectories = true
            panel.canChooseFiles = false
            panel.message = message
            panel.prompt = "Import"

            if panel.runModal() == .OK {
                completion(panel.urls)
            }
        }

        func pickFiles(
            allowMultiple: Bool,
            message: String,
            allowedContentTypes: [UTType]? = nil,
            completion: @escaping ([URL]) -> Void
        ) {
            let panel = NSOpenPanel()
            panel.allowsMultipleSelection = allowMultiple
            panel.canChooseDirectories = false
            panel.canChooseFiles = true
            panel.allowedContentTypes = allowedContentTypes!
            panel.message = message
            panel.prompt = "Select"

            if panel.runModal() == .OK {
                completion(panel.urls)
            }
        }
    }
#else
    import UIKit
    import UniformTypeIdentifiers

    struct iOSPlatformFilePicker: PlatformFilePicking {
        private class ImportPickerDelegate: NSObject, UIDocumentPickerDelegate {
            let completion: ([URL]) -> Void

            init(completion: @escaping ([URL]) -> Void) {
                self.completion = completion
                super.init()
            }

            func documentPicker(
                _ controller: UIDocumentPickerViewController,
                didPickDocumentsAt urls: [URL]
            ) {
                completion(urls)
                cleanup(for: controller)
            }

            func documentPickerWasCancelled(
                _ controller: UIDocumentPickerViewController
            ) {
                cleanup(for: controller)
            }

            private func cleanup(for controller: UIDocumentPickerViewController)
            {
                objc_setAssociatedObject(
                    controller, "delegateKey", nil, .OBJC_ASSOCIATION_RETAIN)
            }
        }

        func pickFolders(
            allowMultiple: Bool,
            message: String,
            completion: @escaping ([URL]) -> Void
        ) {
            guard
                let windowScene = UIApplication.shared.connectedScenes.first
                    as? UIWindowScene,
                let window = windowScene.windows.first,
                let viewController = window.rootViewController
            else {
                return
            }

            let picker = UIDocumentPickerViewController(
                forOpeningContentTypes: [.folder]
            )
            picker.allowsMultipleSelection = allowMultiple

            let delegate = ImportPickerDelegate { urls in
                completion(urls)
            }

            objc_setAssociatedObject(
                picker, "delegateKey", delegate, .OBJC_ASSOCIATION_RETAIN)
            picker.delegate = delegate

            viewController.present(picker, animated: true)
        }

        func pickFiles(
            allowMultiple: Bool,
            message: String,
            allowedContentTypes: [UTType]? = nil,
            completion: @escaping ([URL]) -> Void
        ) {
            guard
                let windowScene = UIApplication.shared.connectedScenes.first
                    as? UIWindowScene,
                let window = windowScene.windows.first,
                let viewController = window.rootViewController
            else {
                return
            }

            let picker = UIDocumentPickerViewController(
                forOpeningContentTypes: allowedContentTypes ?? []
            )
            picker.allowsMultipleSelection = allowMultiple

            let delegate = ImportPickerDelegate { urls in
                completion(urls)
            }

            objc_setAssociatedObject(
                picker, "delegateKey", delegate, .OBJC_ASSOCIATION_RETAIN)
            picker.delegate = delegate

            viewController.present(picker, animated: true)
        }
    }
#endif

// Update the environment key to use the correct picker
struct PlatformFilePickerKey: EnvironmentKey {
    static let defaultValue: PlatformFilePicking = {
        #if os(macOS)
            return MacPlatformFilePicker()
        #else
            return iOSPlatformFilePicker()
        #endif
    }()
}

extension EnvironmentValues {
    var platformFilePicker: PlatformFilePicking {
        get { self[PlatformFilePickerKey.self] }
        set { self[PlatformFilePickerKey.self] = newValue }
    }
}
