//
//  LibraryGridView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/15/24.
//

import SwiftData
import SwiftUI

struct LibraryGridView: View {
    @Binding var navigationPath: NavigationPath
    @Environment(\.modelContext) private var modelContext
    @Environment(\.importManager) private var importManager
    @Environment(\.imageDownloadManager) private var imageDownloadManager
    @Query private var cards: [CardSchemaV1.StereoCard]
    
    @State private var selectedCard: CardSchemaV1.StereoCard?
    @State private var showingStoreTransfer = false
    @State private var isImporting = false
    
    var body: some View {
        CardGridLayout(
            cards: cards,
            selectedCard: $selectedCard,
            onCardSelected: { card in
                navigationPath.append(card)
            }
        )
        .platformNavigationTitle("Library", displayMode: .large)
        .platformToolbar {
            // Leading toolbar items
            HStack {
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
                }
            }
        } trailing: {
            // Trailing toolbar items
            HStack {
                downloadImagesButton
                importMenu
                DatabaseTransferButton()

                #if DEBUG
                    StoreDebugMenu()
                #endif
            }
        }
        .sheet(isPresented: $showingStoreTransfer) {
            StoreTransferView(isImporting: isImporting)
        }
    }
    
    private var downloadImagesButton: some View {
        Button {
            imageDownloadManager?.startImageDownload()
        } label: {
            Label(
                "Download Missing Images",
                systemImage: "arrow.trianglehead.2.clockwise.rotate.90.circle")
        }
    }

    private var importMenu: some View {
        ImportTypeMenu(
            onImport: { urls, type in
                guard let manager = importManager else { return }
                
                switch type {
                case .mods:
                    manager.startImport(from: urls)
                case .crops:
                    startCropImport(urls: urls)
                }
            }
        )
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
