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
    @Environment(\.modelContext) private var modelContext
    
    @State private var importService: BatchImportService
    @State private var cropService: CropUpdateService
    @State private var selectedImportType: ImportType = .mods
    @State private var isImporting = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showConfirmation = false
    @State private var pendingImportURL: URL?
    @State private var fileCount = 0
    
    init(modelContext: ModelContext) {
        _importService = State(initialValue: BatchImportService(modelContext: modelContext))
        _cropService = State(initialValue: CropUpdateService(modelContext: modelContext))
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
            if importService.isProcessing {
                Button(role: .destructive) {
                    importService.cancelImport()
                } label: {
                    Label("Cancel Import", systemImage: "xmark.circle")
                }
                .buttonStyle(.bordered)
            }
            
            Button {
                if importService.importReport != nil {
                    dismiss()
                } else {
                    isImporting = true
                }
            } label: {
                if importService.importReport != nil {
                    Label("Done", systemImage: "checkmark")
                } else {
                    Label("Select Folder", systemImage: "folder.badge.plus")
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(importService.isProcessing)
        }
    }
    
    @ViewBuilder
    private var statusView: some View {
        if importService.isProcessing {
            VStack(spacing: 16) {
                ProgressView()
                    .controlSize(.large)
                
                let progress = importService.progress
                VStack(spacing: 8) {
                    ProgressView(
                        value: Double(progress.completedUnitCount),
                        total: Double(progress.totalUnitCount)
                    )
                    .progressViewStyle(.linear)
                    
                    HStack {
                        Text("\(progress.completedUnitCount) of \(progress.totalUnitCount)")
                            .monospacedDigit()
                        Text("•")
                        Text(
                            "\((Double(progress.completedUnitCount) / Double(progress.totalUnitCount) * 100).formatted(.number.precision(.fractionLength(1))))%"
                        )
                        .monospacedDigit()
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .frame(maxWidth: 300)
            }
        } else if let report = importService.importReport {
            VStack(spacing: 12) {
                Image(systemName: report.failureCount > 0 ? "checkmark.circle.trianglebadge.exclamationmark" : "checkmark.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(report.failureCount > 0 ? .yellow : .green)
                
                Text(report.failureCount > 0 ? "Import Completed with Issues" : "Import Complete")
                    .font(.headline)
                
                Text("\(report.successCount) files imported successfully" + (report.failureCount > 0 ? "\n\(report.failureCount) files failed" : ""))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        } else {
            ContentUnavailableView {
                Label("Select a Folder", systemImage: "folder.badge.plus")
            } description: {
                Text("Choose a folder containing JSON files to import")
            }
        }
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
            .disabled(importService.isProcessing)
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

    private func analyzeDirectory(_ url: URL) async {
        do {
            fileCount =
                try await selectedImportType == .mods
                ? importService.analyzeDirectory(at: url)
                : analyzeForCropUpdates(at: url)

            pendingImportURL = url
            showConfirmation = true
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
                switch selectedImportType {
                case .mods:
                    try await importService.importDirectory(at: url)
                case .crops:
                    try await cropService.updateCropsInBatch(from: [url])
                }
            } catch {
                await handleError(error)
            }
        }
    }

    private func handleError(_ error: Error) async {
        await MainActor.run {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}

private struct ImportConfirmationDialog: View {
    let fileCount: Int
    let importType: ImportType
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Import Confirmation")
                .font(.headline)

            Text(
                "\(importType == .mods ? "Found" : "Will update") \(fileCount) files."
            )
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

#Preview("Import View") {
    let previewContainer = try! PreviewDataManager.shared.container()
    
    return ImportView(modelContext: previewContainer.mainContext)
        .withPreviewStore()
}
