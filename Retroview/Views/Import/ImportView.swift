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
    @State private var viewModel = ImportViewModel()
    @State private var isShowingPicker = false
    
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
            
            if let error = viewModel.error {
                VStack {
                    Text("Import Failed")
                        .font(.headline)
                        .foregroundColor(.red)
                    Text(error.localizedDescription)
                        .font(.subheadline)
                        .multilineTextAlignment(.center)
                }
                .padding()
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
                do {
                    guard let url = try result.get().first else {
                        viewModel.setError(AppError.invalidData("No folder selected"))
                        return
                    }
                    try await viewModel.importFiles(at: url)
                } catch {
                    viewModel.setError(AppError.fileAccessDenied("Could not access selected folder"))
                }
            }
        }
    }
}
