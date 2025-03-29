//
//  DatabaseTransferButton.swift
//  Retroview
//
//  Created by Adam Schuster on 12/14/24.
//

import SwiftUI

struct DatabaseTransferButton: View {
    @State private var showingTransfer = false
    @State private var showImport = false
    let action: () -> Void
    
    init(action: @escaping () -> Void = {}) {
        self.action = action
    }
    
    var body: some View {
        Menu {
            Button {
                showImport = false
                showingTransfer = true
                action()
            } label: {
                Label("Export Library...", systemImage: "arrow.up")
            }
            
            Button {
                showImport = true
                showingTransfer = true
                action()
            } label: {
                Label("Import Library...", systemImage: "arrow.down")
            }
        } label: {
            Label("Library Transfer", systemImage: "arrow.up.arrow.down")
        }
        .sheet(isPresented: $showingTransfer) {
            StoreTransferView(isImporting: showImport)
        }
    }
}

#Preview {
    DatabaseTransferButton()
        .padding()
}
