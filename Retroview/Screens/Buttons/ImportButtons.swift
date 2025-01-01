//
//  ImportButtons.swift
//  Retroview
//
//  Created by Adam Schuster on 12/22/24.
//

import SwiftUI

// MARK: - Import Menu
struct ImportMenu: View {
    let onImport: ([URL], ImportType) -> Void
    
    var body: some View {
        Menu {
            ForEach(ImportType.allCases) { type in
                ImportButton(type: type) { urls in
                    onImport(urls, type)
                }
            }
        } label: {
            Label("Import", systemImage: "square.and.arrow.down")
        }
    }
}

// MARK: - Import Button
struct ImportButton: View {
    @Environment(\.platformFilePicker) private var filePicker
    
    let type: ImportType
    let onImport: ([URL]) -> Void
    
    var body: some View {
        Button {
            filePicker.pickFolders(
                allowMultiple: true,
                message: "Choose folders containing \(type.rawValue)"
            ) { urls in
                onImport(urls)
            }
        } label: {
            Label(type.rawValue, systemImage: type.icon)
        }
    }
}
