//
//  CardActionMenu.swift
//  Retroview
//
//  Created by Adam Schuster on 1/1/25.
//

import QuickLook
import SwiftData
import SwiftUI
import UniformTypeIdentifiers

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
    
    @Query(filter: #Predicate<CollectionSchemaV1.Collection> { collection in
        collection.name != "Favorites"
    }, sort: \CollectionSchemaV1.Collection.name)
    private var collections: [CollectionSchemaV1.Collection]
    
    var body: some View {
        Menu {
            // Share button - shows progress while preparing or share sheet when ready
            Group {
                if let url = card.createSharingURL() {
                    ShareLink(item: url,
                              preview: SharePreview(card.titlePick?.text ?? "Stereo Card"))
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
                ForEach(collections) { collection in
                    Button {
                        toggleCollection(collection)
                    } label: {
                        Label(collection.name,
                              systemImage: collection.hasCard(card) ? "checkmark.circle.fill" : "circle")
                    }
                }
                
                Divider()
                
                Button {
                    showingNewCollectionSheet = true
                } label: {
                    Label("New Collection...", systemImage: "folder.badge.plus")
                }
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
    
    private func toggleCollection(_ collection: CollectionSchemaV1.Collection) {
        if collection.hasCard(card) {
            collection.removeCard(card, context: modelContext)
        } else {
            collection.addCard(card, context: modelContext)
        }
        try? modelContext.save()
    }
}

private enum ShareError: LocalizedError {
    case missingServices
    case imageLoadFailed
    
    var errorDescription: String? {
        switch self {
        case .missingServices:
            "Required services are not available for sharing"
        case .imageLoadFailed:
            "Failed to load image for sharing"
        }
    }
}

// Extension to support use in context menus
extension CardActionMenu {
    func asContextMenu() -> some View {
        Group {
            if let url = card.createSharingURL() {
                ShareLink(item: url,
                          preview: SharePreview(card.titlePick?.text ?? "Stereo Card"))
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
            
            #if os(visionOS)
            Button {
                Task {
                    await card.viewInSpace()
                }
            } label: {
                Label("View in Space", systemImage: "view.3d")
            }
            #endif
            
            ForEach(collections) { collection in
                Button {
                    toggleCollection(collection)
                } label: {
                    Label(collection.name,
                          systemImage: collection.hasCard(card) ? "checkmark.circle.fill" : "circle")
                }
            }
            
            Button {
                showingNewCollectionSheet = true
            } label: {
                Label("New Collection...", systemImage: "folder.badge.plus")
            }
        }
        .onChange(of: card.spatialPhotoData) {
            // Update UI when spatial data changes
            if card.spatialPhotoData != nil {
                sharingURL = card.createSharingURL()
            }
        }
    }
}

extension CardSchemaV1.StereoCard {
    func createSharingURL() -> URL? {
        guard let spatialData = spatialPhotoData else { return nil }

        let title = titlePick?.text ?? "Untitled Card"
        // Sanitize filename by removing invalid characters
        let sanitizedTitle = title.replacingOccurrences(
            of: "[/\\?%*|\"<>]", with: "-", options: .regularExpression)

        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(sanitizedTitle)
            .appendingPathExtension("heic")

        do {
            try spatialData.write(to: tempURL)
            // Set UTType for HEIC image
            try (tempURL as NSURL).setResourceValue(
                UTType.heic.identifier,
                forKey: .typeIdentifierKey
            )
            // Mark as readable to other apps
            try (tempURL as NSURL).setResourceValue(
                true,
                forKey: .isReadableKey
            )
            return tempURL
        } catch {
            print("Failed to create sharing URL: \(error)")
            return nil
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
