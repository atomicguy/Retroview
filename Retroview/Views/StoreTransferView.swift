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
                    
                    Button {
                        Task {
                            do {
                                // Get the URL first
                                exportURL = try await transferManager.exportStore()
                                // Then trigger the export sheet
                                isExporting = true
                            } catch {
                                self.error = error
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
                }
                .padding(.horizontal)
                .fixedSize(horizontal: false, vertical: true)
                
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
            }
            .padding(.top)
            .serifNavigationTitle("Library Transfer")
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
                    do {
                        let url = try result.get()
                        try await transferManager.importStore(from: url)
                        // App needs to restart to use new store
                        exit(0)
                    } catch {
                        self.error = error
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
