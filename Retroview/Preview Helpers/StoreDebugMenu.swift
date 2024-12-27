//
//  StoreDebugMenu.swift
//  Retroview
//
//  Created by Adam Schuster on 12/15/24.
//

import SwiftUI
import SwiftData

#if DEBUG
struct StoreDebugMenu: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showingRestartAlert = false
    @State private var showingSavePreviewAlert = false
    @State private var previewSaveResult: Result<String, Error>?
    @State private var showingResultAlert = false
    
    var body: some View {
        Menu("Debug") {
            Button(role: .destructive) {
                showingRestartAlert = true
            } label: {
                Label("Reset Database", systemImage: "trash")
            }
            
            Divider()
            
            Button {
                showingSavePreviewAlert = true
            } label: {
                Label("Save as Preview Data", systemImage: "square.and.arrow.down")
            }
        }
        .alert("Reset Database", isPresented: $showingRestartAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Reset & Restart", role: .destructive) {
                StoreUtility.resetStore()
                exit(0)
            }
        } message: {
            Text("This will delete all data and restart the app. Are you sure?")
        }
        .alert("Save Preview Data", isPresented: $showingSavePreviewAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Save") {
                Task {
                    do {
                        let result = try await savePreviewStore()
                        previewSaveResult = .success(result)
                    } catch {
                        previewSaveResult = .failure(error)
                    }
                    showingResultAlert = true
                }
            }
        } message: {
            Text("Save current database state as preview data?")
        }
        .alert("Preview Data", isPresented: $showingResultAlert) {
            Button("OK") {}
        } message: {
            switch previewSaveResult {
            case .success(let details):
                Text(details)
            case .failure(let error):
                Text("Failed to save preview data: \(error.localizedDescription)")
            case nil:
                Text("")
            }
        }
    }
    
    private func savePreviewStore() async throws -> String {
        // Use the returned details directly
        return try await PreviewDataManager.shared.exportPreviewStore(from: modelContext)
    }

}
#endif
