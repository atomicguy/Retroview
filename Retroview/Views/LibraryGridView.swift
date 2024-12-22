//
//  LibraryGridView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/15/24.
//

import SwiftData
import SwiftUI

struct LibraryGridView: View {
    @Query(sort: \CardSchemaV1.StereoCard.uuid) private var cards: [CardSchemaV1.StereoCard]
    @Environment(\.modelContext) private var modelContext
    @State private var showingImport = false
    @State private var showingTransfer = false
    @State private var selectedCard: CardSchemaV1.StereoCard?
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            CardGridView(
                cards: cards,
                selectedCard: $selectedCard,
                onCardSelected: { card in navigationPath.append(card) }
            )
            .navigationTitle("Library (\(cards.count) cards)")
            .navigationDestination(for: CardSchemaV1.StereoCard.self) { card in
                CardDetailView(card: card)
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    HStack(spacing: 12) {
                        Button {
                            showingImport = true
                        } label: {
                            Label("Import", systemImage: "square.and.arrow.down")
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
            }
        }
        .sheet(isPresented: $showingImport) {
            ImportView(modelContext: modelContext)
        }
//        .sheet(isPresented: $showingTransfer) {
//            DatabaseTransferView()
//        }
    }
}

#Preview {
    LibraryGridView()
        .withPreviewStore()
        .frame(width: 800, height: 600)
}
