//
//  CardActionMenu.swift
//  Retroview
//
//  Created by Adam Schuster on 1/1/25.
//

import SwiftData
import SwiftUI

struct CardActionMenu: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.spatialPhotoManager) private var spatialManager: SpatialPhotoManager?
    @Environment(\.imageLoader) private var imageLoader: CardImageLoader?
    
    let card: CardSchemaV1.StereoCard
    @State private var showingNewCollectionSheet = false
    @State private var isPreparingSpatialShare = false
    @State private var sharingURL: URL?
    @State private var error: Error?
    
    var body: some View {
        Menu {
            shareButton
            
            #if os(visionOS)
            Button {
                Task {
                    await card.viewInSpace()
                }
            } label: {
                Label("View in Space", systemImage: "view.3d")
            }
            #endif
            
            Menu {
                CardCollectionOptions(
                    card: card,
                    showNewCollectionSheet: $showingNewCollectionSheet
                )
            } label: {
                Label("Add to Collection", systemImage: "folder")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .font(.title2)
        }
        .sheet(isPresented: $showingNewCollectionSheet) {
            CollectionCreationView(card: card)
        }
        .onChange(of: card.spatialPhotoData) {
            if card.spatialPhotoData != nil {
                sharingURL = card.createSharingURL()
            }
        }
    }
    
    // Extract share button to avoid duplication
    @ViewBuilder
    private var shareButton: some View {
        if let url = card.createSharingURL() {
            ShareLink(
                item: url,
                preview: SharePreview(card.titlePick?.text ?? "Stereo Card")
            )
        } else {
            Button("Create Spatial Photo") {
                Task {
                    if let manager = spatialManager,
                       let loader = imageLoader {
                        do {
                            _ = try await manager.getOrCreateSharingURL(for: card, imageLoader: loader)
                        } catch {
                            print("Failed to create spatial photo: \(error)")
                        }
                    }
                }
            }
        }
    }
    
    func asContextMenu() -> some View {
        Group {
            shareButton
            
            #if os(visionOS)
            Button {
                Task {
                    await card.viewInSpace()
                }
            } label: {
                Label("View in Space", systemImage: "view.3d")
            }
            #endif
            
            Menu {
                CardCollectionOptions(
                    card: card,
                    showNewCollectionSheet: $showingNewCollectionSheet
                )
            } label: {
                Label("Add to Collection", systemImage: "folder")
            }
        }
    }
}

#Preview("Direct Menu") {
    CardPreviewContainer { card in
        CardActionMenu(card: card)
    }
}

#Preview("Button Menu") {
    CardPreviewContainer { card in
        CardActionMenu(card: card).asContextMenu()
    }
}
