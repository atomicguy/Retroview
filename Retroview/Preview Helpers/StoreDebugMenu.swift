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
        // Use the new PreviewDataManager
        try await PreviewDataManager.shared.exportPreviewStore(from: modelContext)
        
        // Load and verify the preview container
        let previewContainer = try PreviewDataManager.shared.container()
        let context = previewContainer.mainContext
        
        // Count all entity types
        let cardCount = try context.fetch(FetchDescriptor<CardSchemaV1.StereoCard>()).count
        let titleCount = try context.fetch(FetchDescriptor<TitleSchemaV1.Title>()).count
        let authorCount = try context.fetch(FetchDescriptor<AuthorSchemaV1.Author>()).count
        let subjectCount = try context.fetch(FetchDescriptor<SubjectSchemaV1.Subject>()).count
        let dateCount = try context.fetch(FetchDescriptor<DateSchemaV1.Date>()).count
        let collectionCount = try context.fetch(FetchDescriptor<CollectionSchemaV1.Collection>()).count
        
        // Get file size from the correct location
        let previewStoreURL = PreviewDataManager.shared.previewStoreURL
        let fileSize = try FileManager.default.attributesOfItem(atPath: previewStoreURL.path)[.size] as? Int64 ?? 0
        
        let details = """
            Preview store saved successfully!
            
            Location: \(previewStoreURL.path)
            Size: \(ByteCountFormatter.string(fromByteCount: fileSize, countStyle: .file))
            
            Contains:
            - \(cardCount) cards
            - \(titleCount) titles
            - \(authorCount) authors
            - \(subjectCount) subjects
            - \(dateCount) dates
            - \(collectionCount) collections
            """
        
        return details
    }
}
#endif
