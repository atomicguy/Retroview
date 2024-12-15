//
//  ImportView.swift
//  Retroview
//
//  Created by Adam Schuster on 11/27/24.
//

import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct ImportView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var batchImportService: BatchImportService
    @StateObject private var cropUpdateService: CropUpdateService
    @State private var selectedImportType: ImportType = .mods
    @State private var isImporting = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var processingState: ProcessingState = .ready
    @State private var showConfirmation = false
    @State private var pendingImportURL: URL?
    @State private var fileCount = 0
    
    enum ProcessingState {
        case ready
        case analyzing
        case importing(filesProcessed: Int, totalFiles: Int)
        case completed(totalImported: Int, failedCount: Int)
        case failed(error: String)
        case cancelled
        
        var isImporting: Bool {
            if case .importing = self { return true }
            return false
        }
    }
    
    init(modelContext: ModelContext) {
        _batchImportService = StateObject(
            wrappedValue: BatchImportService(modelContext: modelContext)
        )
        _cropUpdateService = StateObject(
            wrappedValue: CropUpdateService(modelContext: modelContext)
        )
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                importTypePicker
                statusView
                    .padding(.vertical)
                actionButtons
            }
            .padding()
            .frame(minWidth: 400, minHeight: 200)
            .disabled(processingState.isImporting)
            .platformNavigationTitle("Import Cards", displayMode: .inline)
            .platformToolbar {
                EmptyView()
            } trailing: {
                Button("Cancel") {
                    dismiss()
                }
            }
            .sheet(isPresented: $showConfirmation) {
                ImportConfirmationDialog(
                    fileCount: fileCount,
                    importType: selectedImportType,
                    onConfirm: {
                        showConfirmation = false
                        startImport()
                    },
                    onCancel: {
                        showConfirmation = false
                        pendingImportURL = nil
                    }
                )
            }
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [.folder],
                allowsMultipleSelection: false
            ) { result in
                Task {
                    do {
                        let url = try result.get().first!
                        await analyzeDirectory(url)
                    } catch {
                        await handleError(error)
                    }
                }
            }
            .alert("Import Error", isPresented: $showError) {
                Button("OK") { showError = false }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private var importTypePicker: some View {
        Picker("Import Type", selection: $selectedImportType) {
            ForEach(ImportType.allCases) { type in
                Label(type.rawValue, systemImage: type.icon)
                    .tag(type)
            }
        }
        .pickerStyle(.segmented)
        .padding(.horizontal)
    }
    
    private var actionButtons: some View {
        HStack(spacing: 16) {
            if case .importing = processingState {
                Button(role: .destructive) {
                    batchImportService.cancelImport()
                    processingState = .cancelled
                } label: {
                    Label("Cancel Import", systemImage: "xmark.circle")
                }
                .buttonStyle(.bordered)
            }

            Button {
                switch processingState {
                case .ready, .failed, .cancelled:
                    isImporting = true
                case .completed:
                    dismiss()
                default:
                    break
                }
            } label: {
                Label(
                    processingState.buttonLabel,
                    systemImage: processingState.buttonIcon
                )
                .frame(minWidth: 200)
            }
            .buttonStyle(.borderedProminent)
            .disabled(processingState.isImporting)
        }
    }
    
    private func analyzeDirectory(_ url: URL) async {
        processingState = .analyzing
        do {
            fileCount = try await selectedImportType == .mods ?
                batchImportService.analyzeDirectory(at: url) :
                analyzeForCropUpdates(at: url)
            
            pendingImportURL = url
            showConfirmation = true
            processingState = .ready
        } catch {
            await handleError(error)
        }
    }
    
    private func analyzeForCropUpdates(at url: URL) async throws -> Int {
        guard url.startAccessingSecurityScopedResource() else {
            throw ImportError.securityScopedResourceAccessDenied
        }
        defer { url.stopAccessingSecurityScopedResource() }
        
        let fileURLs = try FileManager.default.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: .skipsHiddenFiles
        ).filter { $0.pathExtension.lowercased() == "json" }
        
        return fileURLs.count
    }
    
    private func startImport() {
        guard let url = pendingImportURL else { return }
        
        Task {
            do {
                processingState = .importing(filesProcessed: 0, totalFiles: fileCount)
                
                switch selectedImportType {
                case .mods:
                    try await batchImportService.importDirectory(at: url)
                case .crops:
                    try await importCropUpdates(from: url)
                }
                
                let report = batchImportService.getImportReport()
                await MainActor.run {
                    processingState = .completed(
                        totalImported: report.successCount,
                        failedCount: report.failureCount
                    )
                }
            } catch {
                await handleError(error)
            }
        }
    }
    
    private func importCropUpdates(from url: URL) async throws {
        guard url.startAccessingSecurityScopedResource() else {
            throw ImportError.securityScopedResourceAccessDenied
        }
        defer { url.stopAccessingSecurityScopedResource() }
        
        let fileURLs = try FileManager.default.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: .skipsHiddenFiles
        ).filter { $0.pathExtension.lowercased() == "json" }
        
        try await cropUpdateService.updateCropsInBatch(from: fileURLs)
    }
    
    private func handleError(_ error: Error) async {
        await MainActor.run {
            errorMessage = error.localizedDescription
            showError = true
            processingState = .failed(error: error.localizedDescription)
        }
    }
}

// MARK: - Platform Specific Modifiers

private struct WindowTitleModifier: ViewModifier {
    let title: String

    func body(content: Content) -> some View {
        #if os(macOS)
            content
                .navigationTitle(title)
        #else
            content
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

private struct DismissToolbarModifier: ViewModifier {
    let dismiss: DismissAction

    func body(content: Content) -> some View {
        #if os(macOS)
            content
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
        #else
            content
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
        #endif
    }
}

// MARK: - ImportConfirmationDialog

struct ImportConfirmationDialog: View {
    let fileCount: Int
    let importType: ImportType  // Add this parameter
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Import Confirmation")
                .font(.headline)

            Text("\(importType == .mods ? "Found" : "Will update") \(fileCount) files.")
                .font(.body)

            Text(importType.description)
                .font(.body)
                .foregroundStyle(.secondary)

            HStack(spacing: 16) {
                Button("Cancel", role: .cancel, action: onCancel)
                    .buttonStyle(.bordered)

                Button("Import", action: onConfirm)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(minWidth: 300)
    }
}

// MARK: - ProcessingState Extensions

extension ImportView {
    @ViewBuilder
    var statusView: some View {
        switch processingState {
        case .ready:
            ContentUnavailableView {
                Label("Select a Folder", systemImage: "folder.badge.plus")
            } description: {
                Text("Choose a folder containing JSON files to import")
            }

        case .analyzing:
            VStack(spacing: 12) {
                ProgressView()
                    .controlSize(.large)
                Text("Analyzing directory contents...")
                    .foregroundStyle(.secondary)
            }

        case let .importing(processed, total):
            VStack(spacing: 16) {
                ProgressView()
                    .controlSize(.large)

                VStack(spacing: 8) {
                    // Progress bar
                    ProgressView(
                        value: Double(processed),
                        total: Double(total)
                    )
                    .progressViewStyle(.linear)

                    // Progress details
                    HStack {
                        Text("\(processed) of \(total)")
                            .monospacedDigit()
                        Text("•")
                        Text(
                            "\((Double(processed) / Double(total) * 100).formatted(.number.precision(.fractionLength(1))))%"
                        )
                        .monospacedDigit()
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .frame(maxWidth: 300)
            }

        case let .completed(total, failed):
            VStack(spacing: 12) {
                Image(systemName: failed > 0 ? "checkmark.circle.trianglebadge.exclamationmark" : "checkmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(failed > 0 ? .yellow : .green)

                Text(failed > 0 ? "Import Completed with Issues" : "Import Complete")
                    .font(.headline)

                Text("\(total) files imported successfully" + (failed > 0 ? "\n\(failed) files failed" : ""))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

        case let .failed(error):
            VStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.red)

                Text("Import Failed")
                    .font(.headline)

                Text(error)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 300)
            }

        case .cancelled:
            VStack(spacing: 12) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.orange)

                Text("Import Cancelled")
                    .font(.headline)

                Text("The import operation was cancelled")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Processing State Button Properties

extension ImportView.ProcessingState {
    var buttonLabel: String {
        switch self {
        case .ready:
            "Select Folder"
        case .analyzing:
            "Analyzing..."
        case .importing:
            "Importing..."
        case .completed:
            "Done"
        case .failed:
            "Try Again"
        case .cancelled:
            "Select Folder"
        }
    }

    var buttonIcon: String {
        switch self {
        case .ready:
            "folder.badge.plus"
        case .analyzing:
            "doc.text.magnifyingglass"
        case .importing:
            "arrow.down.doc"
        case .completed:
            "checkmark"
        case .failed:
            "arrow.clockwise"
        case .cancelled:
            "folder.badge.plus"
        }
    }
}

// MARK: - Preview Provider

#Preview("Import View - macOS Light") {
    let container = try! PreviewDataManager.shared.container()
    return ImportView(modelContext: container.mainContext)
        .withPreviewData()
}

#Preview("Import View - macOS Dark") {
    let container = try! PreviewDataManager.shared.container()
    return ImportView(modelContext: container.mainContext)
        .preferredColorScheme(.dark)
        .withPreviewData()
}


