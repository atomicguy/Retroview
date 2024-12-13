//
//  ImportTestView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/10/24.
//

//
//  ImportTestView.swift
//  Retroview
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct ImportTestView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \StereoCard.primaryTitle) private var cards: [StereoCard]
    
    @StateObject private var importManager: CardImportManager
    @State private var showFileImporter = false
    
    init() {
        // Note: We need to use a StateObject wrapper to preserve the manager across view updates
        // The actual ModelContext is injected via the environment
        _importManager = StateObject(wrappedValue: CardImportManager(modelContext: ModelContext(try! ModelContainer(for: StereoCard.self))))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                ImportHeaderView(cardCount: cards.count)
                ImportProgressView(importManager: importManager)
                ImportActionView(showFileImporter: $showFileImporter, isImporting: importManager.isImporting)
                CardListView(cards: cards)
            }
            .navigationTitle("Import Cards")
            .fileImporter(
                isPresented: $showFileImporter,
                allowedContentTypes: [.json],
                allowsMultipleSelection: true
            ) { result in
                Task {
                    await handleSelectedFiles(result)
                }
            }
        }
    }
    
    private func handleSelectedFiles(_ result: Result<[URL], Error>) async {
        do {
            let urls = try result.get()
            try await importManager.importCards(from: urls)
        } catch {
            print("Error in handleSelectedFiles: \(error)")
        }
    }
}

// MARK: - Import Header View
private struct ImportHeaderView: View {
    let cardCount: Int
    
    var body: some View {
        Text("Imported Cards: \(cardCount)")
            .font(.headline)
            .padding()
    }
}

// MARK: - Import Progress View
private struct ImportProgressView: View {
    @ObservedObject var importManager: CardImportManager
    
    var body: some View {
        if importManager.isImporting {
            VStack(spacing: 8) {
                ProgressView(value: importManager.progress)
                    .progressViewStyle(.linear)
                    .padding(.horizontal)
                
                Text(importManager.progressDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom)
        }
    }
}

// MARK: - Import Action View
private struct ImportActionView: View {
    @Binding var showFileImporter: Bool
    let isImporting: Bool
    
    var body: some View {
        Button(action: { showFileImporter = true }) {
            Label("Import JSON Files", systemImage: "square.and.arrow.down")
        }
        .buttonStyle(.borderedProminent)
        .disabled(isImporting)
        .padding(.bottom)
    }
}

// MARK: - Card List View
private struct CardListView: View {
    let cards: [StereoCard]
    
    var body: some View {
        List(cards) { card in
            CardRow(card: card)
        }
    }
}

// MARK: - Card Row View
private struct CardRow: View {
    let card: StereoCard
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(card.primaryTitle)
                .font(.headline)
            
            if let author = card.authors.first?.name {
                Text("Author: \(author)")
                    .font(.subheadline)
            }
            
            if let date = card.dates.first?.dateString {
                Text("Date: \(date)")
                    .font(.subheadline)
            }
            
            Text("UUID: \(card.uuid.uuidString)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ImportTestView()
        .modelContainer(previewContainer)
}

@MainActor
private let previewContainer: ModelContainer = {
    let schema = Schema([StereoCard.self, Author.self, DateReference.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    
    do {
        let container = try ModelContainer(for: schema, configurations: [config])
        // Add sample data if needed
        return container
    } catch {
        fatalError("Failed to create preview container: \(error.localizedDescription)")
    }
}()
