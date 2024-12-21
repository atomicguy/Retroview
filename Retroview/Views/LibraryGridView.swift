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
    
    private let columns = [
        GridItem(.adaptive(minimum: 300, maximum: 400), spacing: 20)
    ]
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ContentView(
                cards: cards,
                selectedCard: $selectedCard,
                onDoubleClick: { card in
                    navigationPath.append(card)
                }
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
        .sheet(isPresented: $showingTransfer) {
            DatabaseTransferView()
        }
    }
}

private struct ContentView: View {
    let cards: [CardSchemaV1.StereoCard]
    @Binding var selectedCard: CardSchemaV1.StereoCard?
    let onDoubleClick: (CardSchemaV1.StereoCard) -> Void
    
    private let columns = [
        GridItem(.adaptive(minimum: 300, maximum: 400), spacing: 20)
    ]
    
    var body: some View {
        if cards.isEmpty {
            EmptyLibraryView()
        } else {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(cards) { card in
                        SelectableThumbnailView(
                            card: card,
                            isSelected: card.id == selectedCard?.id,
                            onSelect: { selectedCard = card },
                            onDoubleClick: { onDoubleClick(card) }
                        )
                    }
                }
                .padding()
            }
        }
    }
}

struct SelectableThumbnailView: View {
    let card: CardSchemaV1.StereoCard
    let isSelected: Bool
    let onSelect: () -> Void
    let onDoubleClick: () -> Void
    
    var body: some View {
        ThumbnailView(card: card)
            .overlay {
                if isSelected {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(.brown, lineWidth: 3)
                }
            }
            .gesture(
                TapGesture(count: 2).onEnded(onDoubleClick)
            )
            .simultaneousGesture(
                TapGesture(count: 1).onEnded(onSelect)
            )
            .contentShape(Rectangle())
    }
}

private struct EmptyLibraryView: View {
    @State private var showingImport = false
    
    var body: some View {
        ContentUnavailableView {
            Label("No Cards", systemImage: "photo.on.rectangle.angled")
        } description: {
            Text("Import some cards to get started")
        } actions: {
            Button {
                showingImport = true
            } label: {
                Label("Import Cards", systemImage: "square.and.arrow.down")
            }
            .buttonStyle(.bordered)
        }
        .sheet(isPresented: $showingImport) {
            if let modelContext = try? ModelContainer(for: CardSchemaV1.StereoCard.self).mainContext {
                ImportView(modelContext: modelContext)
            }
        }
    }
}

#Preview {
    LibraryGridView()
        .withPreviewStore()
        .frame(width: 800, height: 600)
}
