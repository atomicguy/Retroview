//
//  CardListView.swift
//  Retroview
//
//  Created by Adam Schuster on 4/28/24.
//

import SwiftData
import SwiftUI

struct CardListView: View {
    let cards: [CardSchemaV1.StereoCard]
    @State private var selectedCard: CardSchemaV1.StereoCard?
    @State private var isImporting = false
    @ObservedObject var viewModel = ImportViewModel()
    @Environment(\.modelContext) private var context
    
    var body: some View {
        NavigationSplitView(columnVisibility: .constant(.all)) {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(cards) { card in
                        UnifiedCardView(card: card, style: .list)
                            .contentShape(Rectangle())
                            .background(
                                selectedCard?.uuid == card.uuid
                                    ? Color.accentColor.opacity(0.1)
                                    : Color.clear
                            )
                            .onTapGesture {
                                handleCardTap(card)
                            }
                    }
                }
                .padding()
            }
            .navigationSplitViewColumnWidth(min: 500, ideal: 600)
            .toolbar {
                Button(action: { isImporting = true }) {
                    Label("Import", systemImage: "square.and.arrow.down")
                }
            }
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [.json],
                allowsMultipleSelection: true
            ) { result in
                handleImport(result)
            }
        } detail: {
            if let selectedCard {
                // Using an id modifier to force view recreation when selection changes
                StereoView(card: selectedCard)
                    .id(selectedCard.uuid)
                    .navigationSplitViewColumnWidth(min: 250, ideal: 300)
            } else {
                Text("Select a card to view in stereo")
                    .foregroundStyle(.secondary)
                    .navigationSplitViewColumnWidth(min: 250, ideal: 300)
            }
        }
    }
    
    private func handleCardTap(_ card: CardSchemaV1.StereoCard) {
        // If selecting the same card, deselect it
        if selectedCard?.uuid == card.uuid {
            selectedCard = nil
        } else {
            selectedCard = card
        }
    }
    
    private func handleImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            for url in urls {
                viewModel.importData(fromFile: url, context: context)
            }
        case .failure(let error):
            print("Error importing file: \(error.localizedDescription)")
        }
    }
}

#Preview {
    CardsPreviewContainer { cards in
        NavigationStack {
            CardListView(cards: cards)
        }
    }
}
