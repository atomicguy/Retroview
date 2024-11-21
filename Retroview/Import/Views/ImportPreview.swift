//
//  ImportPreview.swift
//  Retroview
//
//  Created by Adam Schuster on 11/20/24.
//

import SwiftUI
import SwiftData

struct ImportPreview: View {
    @StateObject private var viewModel = ImportViewModel()
    @Environment(\.modelContext) private var context
    
    var body: some View {
        VStack {
            if viewModel.state.isImporting {
                ProgressView("Importing...")
                    .progressViewStyle(.circular)
            }
            
            if let error = viewModel.state.error {
                Text("Error: \(error.localizedDescription)")
                    .foregroundColor(.red)
            }
            
            Button("Import Sample") {
                // Sample URL for preview
                guard let url = Bundle.main.url(forResource: "sample", withExtension: "json") else { return }
                viewModel.importData(fromFile: url, context: context)
            }
        }
        .padding()
    }
}

#Preview("Import View") {
    ImportPreview()
        .modelContainer(PreviewHelper.shared.modelContainer)
}
