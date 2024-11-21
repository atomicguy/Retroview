import SwiftData
import SwiftUI

import SwiftData
import SwiftUI

@MainActor
class ImportViewModel: ObservableObject {
    @Published private(set) var state = ImportState.initial
    
    // MARK: - Public Methods
    
    func importData(fromFile fileURL: URL, context: ModelContext) {
        Task {
            do {
                state.isImporting = true
                state.progress = 0
                
                let jsonData = try await readFile(fileURL)
                state.progress = 0.3
                
                let cards = try await CardImporter.createCards(from: jsonData)
                state.progress = 0.6
                
                try await saveCards(cards, to: context)
                state.progress = 1.0
                
                // Reset state after successful import
                state = .initial
            } catch {
                state.error = error
                state.isImporting = false
            }
        }
    }
    
    // MARK: - Private Methods
    
    private func readFile(_ url: URL) async throws -> Data {
        return try await withCheckedThrowingContinuation { continuation in
            guard url.startAccessingSecurityScopedResource() else {
                continuation.resume(throwing: ImportError.fileReadError("Cannot access file"))
                return
            }
            
            defer { url.stopAccessingSecurityScopedResource() }
            
            do {
                let data = try Data(contentsOf: url)
                continuation.resume(returning: data)
            } catch {
                continuation.resume(throwing: ImportError.fileReadError(error.localizedDescription))
            }
        }
    }
    
    private func saveCards(_ cards: [CardSchemaV1.StereoCard], to context: ModelContext) async throws {
        try await Task { @MainActor in
            for card in cards {
                context.insert(card)
                
                // Start image downloads but don't wait for them
                Task {
                    try? await card.downloadImage(forSide: "front")
                    try? await card.downloadImage(forSide: "back")
                }
            }
            
            do {
                try context.save()
            } catch {
                throw ImportError.saveError(error.localizedDescription)
            }
        }.value
    }
}
