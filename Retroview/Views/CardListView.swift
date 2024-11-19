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
    @State private var isImporting = false
    @ObservedObject var viewModel = ImportViewModel()
    @Environment(\.modelContext) private var context
    @Environment(\.openWindow) private var openWindow
    @Environment(\.dismissWindow) private var dismissWindow
    @EnvironmentObject private var windowStateManager: WindowStateManager

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(cards) { card in
                    CardRow(card: card)
                        .contentShape(Rectangle())
                        .background(
                            windowStateManager.selectedCardId == card.uuid
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
        .toolbar {
            Button(action: { isImporting = true }) {
                Label("Import", systemImage: "square.and.arrow.down")
            }
        }
        .fileImporter(isPresented: $isImporting, allowedContentTypes: [.json], allowsMultipleSelection: true) { result in
            handleImport(result)
        }
    }

    private func handleCardTap(_ card: CardSchemaV1.StereoCard) {
        let identifier = StereoCardIdentifier(from: card)
        windowStateManager.selectCard(card)

        if windowStateManager.isDetailWindowOpen {
            dismissWindow(id: "stereo-detail")
            openWindow(id: "stereo-detail", value: identifier)
        } else {
            openWindow(id: "stereo-detail", value: identifier)
            windowStateManager.isDetailWindowOpen = true
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
