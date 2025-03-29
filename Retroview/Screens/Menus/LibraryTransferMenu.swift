//
//  LibraryTransferMenu.swift
//  Retroview
//
//  Created by Adam Schuster on 3/25/25.
//

import SwiftUI

struct LibraryTransferMenu: View {
    @State private var showingTransfer = false
    @State private var isImporting = false
    let toolbarStyle: Bool
    
    init(toolbarStyle: Bool = false) {
        self.toolbarStyle = toolbarStyle
    }
    
    var body: some View {
        Group {
            if toolbarStyle {
                // Simple button for toolbar - directly open export view by default
                Button {
                    showingTransfer = true
                } label: {
                    if toolbarStyle {
                        Label("Transfer Library", systemImage: "arrow.triangle.swap")
                            .labelStyle(.iconOnly)
                    } else {
                        Label("Transfer Library", systemImage: "arrow.triangle.swap")
                    }
                }
                .help("Export or import library")
                .sheet(isPresented: $showingTransfer) {
                    StoreTransferView(isImporting: isImporting)
                }
            } else {
                // Full menu for other contexts
                Menu {
                    Button {
                        isImporting = false
                        showingTransfer = true
                    } label: {
                        Label("Export Library...", systemImage: "square.and.arrow.up")
                    }
                    
                    Button {
                        isImporting = true
                        showingTransfer = true
                    } label: {
                        Label("Import Library...", systemImage: "square.and.arrow.down")
                    }
                } label: {
                    Label("Library Transfer", systemImage: "arrow.triangle.swap")
                }
                .sheet(isPresented: $showingTransfer) {
                    StoreTransferView(isImporting: isImporting)
                }
            }
        }
    }
}

#Preview("Menu Style") {
    LibraryTransferMenu()
        .padding()
}

#Preview("Toolbar Style") {
    LibraryTransferMenu(toolbarStyle: true)
        .padding()
}
