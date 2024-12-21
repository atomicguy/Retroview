//
//  DatabaseTransferView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/14/24.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct DatabaseTransferView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var exportProgress = false
    @State private var importProgress = false
    @State private var errorMessage: String?
    @State private var currentProgress: DatabaseTransferManager.ImportProgress?
    @State private var progress: Double = 0
    
    private let transferManager = DatabaseTransferManager()
    
    var body: some View {
        NavigationStack {
            ZStack {
                List {
                    Section {
                        exportButton
                        importButton
                    }
                    
                    if let errorMessage {
                        Section {
                            Text(errorMessage)
                                .foregroundStyle(.red)
                        }
                    }
                }
                .disabled(isProcessing)
                
                if isProcessing {
                    ProgressView {
                        VStack(spacing: 12) {
                            Text(currentProgress?.message ?? "Processing...")
                                .font(.headline)
                            
                            if case .importingCards(let completed, let total) = currentProgress?.phase {
                                ProgressView(value: Double(completed), total: Double(total)) {
                                    Text("\(completed) of \(total)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .frame(width: 200)
                            }
                            
                            if case .importingCollections(let completed, let total) = currentProgress?.phase {
                                ProgressView(value: Double(completed), total: Double(total)) {
                                    Text("\(completed) of \(total)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .frame(width: 200)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.ultraThinMaterial)
                }
            }
            .navigationTitle("Database Transfer")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .frame(minWidth: 400, minHeight: 200)
    }
    
    private var isProcessing: Bool {
        exportProgress || importProgress
    }
    
    private var exportButton: some View {
        Button {
            Task {
                await exportDatabase()
            }
        } label: {
            Label("Export Database", systemImage: "square.and.arrow.up")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .disabled(isProcessing)
    }
    
    private var importButton: some View {
        Button {
            Task {
                await importDatabase()
            }
        } label: {
            Label("Import Database", systemImage: "square.and.arrow.down")
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .disabled(isProcessing)
    }
    
    @MainActor
    private func exportDatabase() async {
        exportProgress = true
        defer { exportProgress = false }
        
        do {
            let data = try await transferManager.exportDatabase(from: modelContext)
            
            if let url = try await PlatformFileHandler.exportFile(
                data: data,
                defaultName: "retroview_database.rvdb"
            ) {
                #if !os(macOS)
                // On iOS/visionOS, we need to present a share sheet for the exported file
                await shareFile(at: url)
                #endif
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    @MainActor
    private func importDatabase() async {
        importProgress = true
        defer { importProgress = false }
        
        do {
            if let url = try await PlatformFileHandler.importFile() {
                let data = try Data(contentsOf: url, options: .mappedIfSafe)
                try await transferManager.importDatabase(
                    from: data,
                    into: modelContext
                ) { progress in
                    currentProgress = progress
                }
            }
        } catch {
            errorMessage = "Import failed: \(error.localizedDescription)"
        }
    }
    
    #if !os(macOS)
    private func shareFile(at url: URL) async {
        let activityVC = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil
        )
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let controller = scene.windows.first?.rootViewController {
            await MainActor.run {
                controller.present(activityVC, animated: true)
            }
        }
    }
    #endif
}
