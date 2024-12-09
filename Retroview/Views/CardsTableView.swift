//
//  CardsTableView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/8/24.
//

import SwiftData
import SwiftUI

struct CardsTableView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedCard: StereoCard?
    @State private var showingImporter = false
    @State private var importError: Error?
    @State private var showingError = false
    @State private var importer = MODSJSONImporter()
    
    var body: some View {
        NavigationSplitView {
            CardsListView(selectedCard: $selectedCard, importer: importer)
                .navigationTitle("Stereo Cards")
                .toolbar {
                    Button("Import JSON") {
                        showingImporter = true
                    }
                    .disabled(importer.isImporting)
                }
        } detail: {
            if let selectedCard {
                CardDetailView(card: selectedCard)
            } else {
                Text("Select a card")
            }
        }
        .fileImporter(
            isPresented: $showingImporter,
            allowedContentTypes: [.json]
        ) { result in
            switch result {
            case .success(let url):
                do {
                    let data = try Data(contentsOf: url)
                    try importer.importJSON(data, context: modelContext)
                } catch {
                    importError = error
                    showingError = true
                    print("File import error: \(error)")
                }
            case .failure(let error):
                importError = error
                showingError = true
                print("File picker error: \(error)")
            }
        }
        .alert("Import Error", isPresented: $showingError, presenting: importError) { _ in
            Button("OK") {}
        } message: { error in
            Text(error.localizedDescription)
        }
    }
}
