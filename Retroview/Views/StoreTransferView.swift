//
//  DataStoreTransfer.swift
//  Retroview
//
//  Created by Adam Schuster on 12/22/24.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct StoreTransferView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isExporting = false
    @State private var isImporting = false
    @State private var error: Error?
    @State private var exportURL: URL?
    @State private var showProgress = false
    
    private let transferManager = StoreTransferManager.shared
    
    // Track whether we're in import mode
    let startWithImport: Bool
    
    init(isImporting: Bool = false) {
        self.startWithImport = isImporting
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Main action buttons
                VStack(spacing: 16) {
                    Button {
                        isImporting = true
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.down")
                            Text("Import Library")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(showProgress)
                    
                    Button {
                        Task {
                            showProgress = true
                            do {
                                // Get the URL first
                                exportURL = try await transferManager.exportStore()
                                showProgress = false
                                // Then trigger the export sheet
                                isExporting = true
                            } catch {
                                self.error = error
                                showProgress = false
                            }
                        }
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                            Text("Export Library")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .disabled(showProgress)
                }
                .padding(.horizontal)
                .fixedSize(horizontal: false, vertical: true)
                
                // Progress indicator
                if showProgress {
                    VStack(spacing: 12) {
                        ProgressView()
                            .controlSize(.large)
                        Text(isImporting ? "Preparing to import..." : "Preparing export...")
                            .foregroundStyle(.secondary)
                        Text("This may take several minutes for large libraries")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                
                // Error display if present
                if let error {
                    VStack {
                        Text("Error")
                            .font(.headline)
                        Text(error.localizedDescription)
                            .foregroundStyle(.red)
                    }
                    .padding()
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Import note
                if startWithImport {
                    Text("Note: The app will restart after import.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 8)
                }
            }
            .padding(.top)
            .platformNavigationTitle("Library Transfer", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .fileExporter(
                isPresented: $isExporting,
                document: StoreDocument(storeURL: exportURL),
                contentType: .retroviewStore,
                defaultFilename: "retroview-library"
            ) { result in
                if case .failure(let error) = result {
                    self.error = error
                }
                // Clear the export URL after use
                exportURL = nil
            }
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [.retroviewStore]
            ) { result in
                Task {
                    showProgress = true
                    do {
                        let url = try result.get()
                        try await transferManager.importStore(from: url)
                        // App needs to restart to use new store
                        // Note: importStore already calls exit(0)
                    } catch {
                        self.error = error
                        showProgress = false
                    }
                }
            }
        }
        .frame(minWidth: 300, minHeight: 200)
        .onAppear {
            // If we're starting in import mode, show the picker immediately
            if startWithImport {
                isImporting = true
            }
        }
    }
}

#Preview("Transfer View") {
    StoreTransferView()
}
