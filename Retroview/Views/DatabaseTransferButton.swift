//
//  DatabaseTransferButton.swift
//  Retroview
//
//  Created by Adam Schuster on 12/14/24.
//

import SwiftUI

struct DatabaseTransferButton: View {
    @State private var showingTransfer = false
    let action: () -> Void
    
    init(action: @escaping () -> Void = {}) {
        self.action = action
    }
    
    var body: some View {
        Button {
            showingTransfer = true
            action()
        } label: {
            Label("Database Transfer", systemImage: "arrow.triangle.2.circlepath.doc")
        }
        .sheet(isPresented: $showingTransfer) {
            DatabaseTransferView()
        }
    }
}

#Preview {
    DatabaseTransferButton()
}
