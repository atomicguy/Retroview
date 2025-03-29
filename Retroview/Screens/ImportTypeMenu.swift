//
//  ImportTypeMenu.swift
//  Retroview
//
//  Created by Adam Schuster on 12/22/24.
//

import SwiftData
import SwiftUI

struct ImportTypeMenu: View {
    @Environment(\.platformFilePicker) private var filePicker
    let onImport: ([URL], ImportType) -> Void

    var body: some View {
        Menu {
            ForEach(ImportType.allCases) { type in
                Button {
                    selectImportFolder(type: type)
                } label: {
                    Label(type.rawValue, systemImage: type.icon)
                }
            }
        } label: {
            Label("Import", systemImage: "square.and.arrow.down")
        }
    }
    
    private func selectImportFolder(type: ImportType) {
        filePicker.pickFolders(
            allowMultiple: true,
            message: "Choose folders containing \(type.rawValue)"
        ) { urls in
            onImport(urls, type)
        }
    }
}
