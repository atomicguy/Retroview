//
//  ImportView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/9/24.
//

import SwiftData
import SwiftUI

struct ImportView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: ImportViewModel
    @State private var isShowingPicker = false
    
    init(modelContext: ModelContext) {
        _viewModel = State(initialValue: ImportViewModel())
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if let progress = viewModel.progress {
                ImportProgressView(progress: progress)
            } else {
                ContentUnavailableView {
                    Label("Import Cards", systemImage: "square.and.arrow.down")
                } description: {
                    Text("Select a folder containing JSON files to import")
                } actions: {
                    Button("Select Folder") {
                        isShowingPicker = true
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding()
        .frame(minWidth: 400, minHeight: 300)
        .navigationTitle("Import Cards")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .fileImporter(
            isPresented: $isShowingPicker,
            allowedContentTypes: [.folder],
            allowsMultipleSelection: false
        ) { result in
            Task {
                if let url = try? result.get().first {
                    await viewModel.importFiles(at: url)
                }
            }
        }
    }
}
