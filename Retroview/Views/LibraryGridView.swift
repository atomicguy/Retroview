//
//  LibraryGridView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/15/24.
//

import SwiftData
import SwiftUI

struct LibraryGridView: View {
    // Use @Query directly with proper sorting and filtering
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
            Group {
                if cards.isEmpty {
                    ContentUnavailableView {
                        Label(
                            "No Cards", systemImage: "photo.on.rectangle.angled"
                        )
                    } description: {
                        Text("Import some cards to get started")
                    } actions: {
                        Button {
                            showingImport = true
                        } label: {
                            Label(
                                "Import Cards",
                                systemImage: "square.and.arrow.down")
                        }
                        .buttonStyle(.bordered)
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(cards) { card in
                                ThumbnailView(card: card)
                            }
                        }
                        .padding()
                        .task {
                            let imageIds = cards.compactMap(\.imageFrontId)
                            ImageCacheService.shared.prefetch(
                                imageIds: imageIds)
                        }
                    }
                }
            }
            .navigationTitle("Library (\(cards.count) cards)")
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

#Preview {
    LibraryGridView()
        .withPreviewStore()
        .frame(width: 800, height: 600)
}
