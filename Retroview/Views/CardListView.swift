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

    @ObservedObject var viewModel = ImportViewModel()
    @Environment(\.modelContext) private var context

    @State private var isImporting = false

    var body: some View {
        Button(
            action: { isImporting = true },
            label: {
                Label("Import", systemImage: "square.and.arrow.down")
            }
        )
        .fileImporter(
            isPresented: $isImporting, allowedContentTypes: [.json],
            allowsMultipleSelection: true
        ) { result in
            switch result {
            case .success(let urls):
                for url in urls {
                    viewModel.importData(fromFile: url, context: context)
                }
            case .failure(let error):
                print("Error importing file: \(error.localizedDescription)")
            }
        }
        List {
            ForEach(cards) { card in
                NavigationLink(destination: CardDetailView(card: card)) {
                    CardView(card: card)
                }
            }
        }
        //        .navigationDestination(for: CardSchemaV1.StereoCard.self) { card in
        //            CardDetailView(card: card)
        //        }
    }
}

#Preview {
    NavigationStack {
        CardListView(cards: SampleData.shared.cards)
    }
    .modelContainer(SampleData.shared.modelContainer)
}
