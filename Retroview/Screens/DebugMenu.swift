//
//  DebugMenu.swift
//  Retroview
//
//  Created by Adam Schuster on 11/29/24.
//

import SwiftData
import SwiftUI

#if DEBUG
struct DebugMenu: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showingRestartAlert = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    var body: some View {
        Menu {
            Section {
                Button(role: .destructive) {
                    showingRestartAlert = true
                } label: {
                    Label("Reset Store & Restart", systemImage: "trash")
                }
            }
            
            Section {
                if isLoading {
                    ProgressView()
                } else {
                    Button {
                        Task { await loadDemoData() }
                    } label: {
                        Label("Load Demo Data", systemImage: "square.and.arrow.down")
                    }
                }
            }
        } label: {
            Label("Debug", systemImage: "ladybug")
        }
        .alert("Reset Data Store",
               isPresented: $showingRestartAlert)
        {
            Button("Cancel", role: .cancel) {}
            Button("Reset & Restart", role: .destructive) {
                DevelopmentFlags.shouldResetStore = true
                restartApp()
            }
        } message: {
            Text("This will delete all data and restart the app. Are you sure?")
        }
        .alert("Error Loading Demo Data",
               isPresented: .init(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
               )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            if let error = errorMessage {
                Text(error)
            }
        }
    }
    
    private func loadDemoData() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            print("Starting demo data load...")
            try await DebugDataLoader.shared.loadDemoData(into: modelContext)
            print("Demo data loaded successfully")
        } catch {
            print("Failed to load demo data: \(error)")
            errorMessage = error.localizedDescription
        }
    }
    
    private func restartApp() {
        #if os(macOS)
        let task = Process()
        task.executableURL = URL(fileURLWithPath: Bundle.main.executablePath!)
        try? task.run()
        NSApp.terminate(nil)
        #else
        exit(0)
        #endif
    }
}

extension DebugMenu {
    @MainActor
    private func resetStoreAndRestart() {
        Task {
            do {
                // Show loading state
                print("Starting store cleanup...")
                
                // Perform cleanup
                try await StoreCleanupService.shared.cleanupStore()
                
                print("Store cleanup completed, restarting app...")
                
                // Restart the app
                DispatchQueue.main.async {
                    restartApp()
                }
            } catch {
                print("Failed to cleanup store: \(error)")
            }
        }
    }
    
    private func loadDemoData() {
        Task {
            do {
                // Reset store first
                try await StoreCleanupService.shared.cleanupStore()
                
                // Then load new data
                try await PreviewDataManager.shared.populatePreviewData()
                print("Demo data loaded successfully")
            } catch {
                print("Failed to load demo data: \(error)")
            }
        }
    }
}
#endif

#Preview("Debug Menu") {
    DebugMenu()
        .withPreviewData()
}
