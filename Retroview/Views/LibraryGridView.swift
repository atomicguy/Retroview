//
//  LibraryGridView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/15/24.
//

import SwiftData
import SwiftUI

struct LibraryGridView: View {
    @Query(sort: \CardSchemaV1.StereoCard.uuid) private var cards:
        [CardSchemaV1.StereoCard]
    @Environment(\.modelContext) private var modelContext

    @State private var showingImport = false
    @State private var showingTransfer = false

    private let columns = [
        GridItem(.adaptive(minimum: 300, maximum: 400), spacing: 20) 
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(cards) { card in
                        CardThumbnail(card: card)
                    }
                }
                .padding()
            }
            .navigationTitle("Library")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    HStack(spacing: 12) {
                        Button {
                            showingImport = true
                        } label: {
                            Label(
                                "Import", systemImage: "square.and.arrow.down")
                        }

                        Button {
                            showingTransfer = true
                        } label: {
                            Label(
                                "Transfer", systemImage: "arrow.up.arrow.down")
                        }

                        #if DEBUG
                            StoreDebugMenu()
                        #endif

                        #if DEBUG
                            Button(role: .destructive) {
                                StoreUtility.resetStore()
                                exit(0)  // Restart the app
                            } label: {
                                Label("Reset Database", systemImage: "trash")
                            }
                        #endif
                    }
                }
            }
        }
        .sheet(isPresented: $showingImport) {
            ImportView(modelContext: modelContext)
        }
        .sheet(isPresented: $showingTransfer) {
            DatabaseTransferView()
        }
    }
}

struct CardThumbnail: View {
    let card: CardSchemaV1.StereoCard
    @State private var image: CGImage?
    
    var body: some View {
        ZStack {
            if let image {
                Image(decorative: image, scale: 1.0)
                    .resizable()
                    .scaledToFit()
                    .aspectRatio(CGFloat(image.width) / CGFloat(image.height), contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(.gray.opacity(0.2))
                    .aspectRatio(2, contentMode: .fit) // Default placeholder ratio
                    .overlay {
                        if card.imageFront != nil {
                            ProgressView()
                        } else {
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundStyle(.secondary)
                        }
                    }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure it scales properly in the grid
        .task {
            if let imageData = card.imageFront {
                image = await DefaultImageLoader().createCGImage(from: imageData)
            }
        }
    }
}

#Preview {
    LibraryGridView()
        .withPreviewStore()
        .frame(width: 800, height: 600)
}
