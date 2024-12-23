//
//  LibraryGridView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/15/24.
//

import SwiftData
import SwiftUI

struct LibraryGridView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.importManager) private var importManager
    @Environment(\.imageDownloadManager) private var imageDownloadManager
    
    @State private var showingImport = false
    @State private var showingTransfer = false
    @State private var totalCardCount: Int = 0
    
    var body: some View {
        PaginatedNavigableGrid(
            emptyTitle: "No Cards",
            emptyDescription: "Your library is empty",
            header: { EmptyView() } // Use an empty header if not needed here
        )
        .toolbar {
            ToolbarItemGroup {
                if let manager = importManager, manager.isImporting {
                    ImportProgressIndicator(importManager: manager)
                }

                if let manager = imageDownloadManager, manager.isDownloading {
                    BackgroundProgressIndicator(
                        isProcessing: manager.isDownloading,
                        processedCount: manager.processedCardCount,
                        totalCount: manager.missingImageCount,
                        onCancel: { manager.cancelDownload() }
                    )
                } else {
                    Button {
                        imageDownloadManager?.startImageDownload()
                    } label: {
                        Label(
                            "Download Missing Images",
                            systemImage: "arrow.trianglehead.2.clockwise.rotate.90.circle"
                        )
                    }
                }

                ImportTypeMenu { urls, type in
                    if let manager = importManager {
                        switch type {
                        case .mods:
                            manager.startImport(from: urls)
                        case .crops:
                            startCropImport(urls: urls)
                        }
                    }
                }

                Button {
                    showingTransfer = true
                } label: {
                    Label("Transfer", systemImage: "arrow.up.arrow.down")
                }

                #if DEBUG
                StoreDebugMenu()
                #endif
            }
        }
        .task {
            let descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
            totalCardCount = (try? modelContext.fetchCount(descriptor)) ?? 0
        }
    }
    
    private func startCropImport(urls: [URL]) {
        let cropUpdateService = CropUpdateService(modelContext: modelContext)
        
        Task {
            do {
                try await cropUpdateService.updateCropsInBatch(from: urls)
            } catch {
                print("Crop import failed: \(error)")
            }
        }
    }
}

struct ImportTypeMenu: View {
    let onImport: ([URL], ImportType) -> Void

    var body: some View {
        Menu {
            ForEach(ImportType.allCases) { type in
                ImportButton(type: type) { urls in
                    onImport(urls, type)
                }
            }
        } label: {
            Label("Import", systemImage: "square.and.arrow.down")
        }
    }
}

struct ImportButton: View {
    let type: ImportType
    let onImport: ([URL]) -> Void

    var body: some View {
        Button {
            selectImportFolder(type: type)
        } label: {
            Label(type.rawValue, systemImage: type.icon)
        }
    }

    private func selectImportFolder(type: ImportType) {
        #if os(macOS)
            let panel = NSOpenPanel()
            panel.allowsMultipleSelection = true
            panel.canChooseDirectories = true
            panel.canChooseFiles = false
            panel.message = "Choose folders containing \(type.rawValue)"
            panel.prompt = "Import"

            if panel.runModal() == .OK {
                onImport(panel.urls)
            }
        #else
            // iOS/iPadOS document picker
            let picker = UIDocumentPickerViewController(
                forOpeningContentTypes: [.folder],
                asCopy: false
            )
            picker.allowsMultipleSelection = true

            let viewController = UIApplication.shared.windows.first?
                .rootViewController
            viewController?.present(picker, animated: true)

        // Assuming you're using a coordinator pattern or closure-based approach
        // to handle document picker selection
        #endif
    }
}

// Helper view for picking import directory
struct ImportDirectoryPicker: View {
    let onSelect: ([URL]) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        #if os(macOS)
            EmptyView()
                .onAppear {
                    let panel = NSOpenPanel()
                    panel.allowsMultipleSelection = true
                    panel.canChooseDirectories = true
                    panel.canChooseFiles = false
                    panel.message = "Choose folders containing MODS JSON files"
                    panel.prompt = "Import"

                    if panel.runModal() == .OK {
                        onSelect(panel.urls)
                    }
                    dismiss()
                }
        #else
            // iOS/iPadOS document picker
            DocumentPicker(
                allowedContentTypes: [.folder],
                allowsMultipleSelection: true
            ) { urls in
                onSelect(urls)
                dismiss()
            }
        #endif
    }
}

#if !os(macOS)
    // iOS/iPadOS document picker wrapper
    struct DocumentPicker: UIViewControllerRepresentable {
        let allowedContentTypes: [UTType]
        let allowsMultipleSelection: Bool
        let onSelect: ([URL]) -> Void

        func makeUIViewController(context: Context)
            -> UIDocumentPickerViewController
        {
            let picker = UIDocumentPickerViewController(
                forOpeningContentTypes: allowedContentTypes)
            picker.allowsMultipleSelection = allowsMultipleSelection
            picker.delegate = context.coordinator
            return picker
        }

        func updateUIViewController(
            _ uiViewController: UIDocumentPickerViewController, context: Context
        ) {}

        func makeCoordinator() -> Coordinator {
            Coordinator(onSelect: onSelect)
        }

        class Coordinator: NSObject, UIDocumentPickerDelegate {
            let onSelect: ([URL]) -> Void

            init(onSelect: @escaping ([URL]) -> Void) {
                self.onSelect = onSelect
            }

            func documentPicker(
                _ controller: UIDocumentPickerViewController,
                didPickDocumentsAt urls: [URL]
            ) {
                onSelect(urls)
            }
        }
    }
#endif

//#Preview {
//    LibraryGridView()
//        .withPreviewStore()
//        .frame(width: 800, height: 600)
//}
