//
//  CropUpdateService.swift
//  Retroview
//
//  Created by Adam Schuster on 12/14/24.
//

import Foundation
import SwiftData
import Combine

@MainActor
class CropUpdateService: ObservableObject {
    @Published private(set) var currentProgress: Progress?
    @Published private(set) var isProcessing = false
    
    private let modelContext: ModelContext
    private var progressContinuation: AsyncStream<Progress>.Continuation?
    private var cancellationToken: Task<Void, Error>?
    
    var progressUpdates: AsyncStream<Progress> {
        AsyncStream { continuation in
            self.progressContinuation = continuation
            if let progress = currentProgress {
                continuation.yield(progress)
            }
        }
    }
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func updateCrops(from url: URL) async throws {
        isProcessing = true
        defer { isProcessing = false }
        
        let data = try Data(contentsOf: url)
        let cropUpdate = try JSONDecoder().decode(CropUpdateJSON.self, from: data)
        
        print("\n🔍 Processing crop update for UUID: \(cropUpdate.uuid)")
        
        // Verify the card exists before attempting update
        guard let card = try await findExistingCard(uuid: cropUpdate.uuid) else {
            ImportLogger.log(.warning, "Skipping crop update - card not found", file: url.lastPathComponent)
            return
        }
        
        print("✅ Found matching card, updating crops")
        
        // Update left crop
        let leftCrop = CropSchemaV1.Crop(
            x0: cropUpdate.left.x0,
            y0: cropUpdate.left.y0,
            x1: cropUpdate.left.x1,
            y1: cropUpdate.left.y1,
            score: cropUpdate.left.score,
            side: cropUpdate.left.side
        )
        
        // Update right crop
        let rightCrop = CropSchemaV1.Crop(
            x0: cropUpdate.right.x0,
            y0: cropUpdate.right.y0,
            x1: cropUpdate.right.x1,
            y1: cropUpdate.right.y1,
            score: cropUpdate.right.score,
            side: cropUpdate.right.side
        )
        
        // Update card crops
        card.leftCrop = leftCrop
        card.rightCrop = rightCrop
        
        try modelContext.save()
        ImportLogger.log(.info, "Updated crops for card: \(cropUpdate.uuid)")
    }
    
    private func findExistingCard(uuid: String) async throws -> CardSchemaV1.StereoCard? {
        let cardUUID = UUID(uuidString: uuid.lowercased())
        guard let cardUUID else {
            print("❌ Invalid UUID format: \(uuid)")
            return nil
        }
        
        let descriptor = FetchDescriptor<CardSchemaV1.StereoCard>(
            predicate: #Predicate<CardSchemaV1.StereoCard> { card in
                card.uuid == cardUUID
            }
        )
        
        let cards = try modelContext.fetch(descriptor)
        if cards.isEmpty {
            print("❌ No card found with UUID: \(uuid)")
            return nil
        }
        
        return cards.first
    }
    
    func updateCropsInBatch(from urls: [URL]) async throws {
        isProcessing = true
        defer { isProcessing = false }
        
        let progress = Progress(totalUnitCount: Int64(urls.count))
        currentProgress = progress
        progressContinuation?.yield(progress)
        
        cancellationToken = Task {
            for url in urls {
                if Task.isCancelled { break }
                
                do {
                    print("\n📄 Processing file: \(url.lastPathComponent)")
                    try await updateCrops(from: url)
                    progress.completedUnitCount += 1
                    progressContinuation?.yield(progress)
                } catch {
                    ImportLogger.log(.error, "Failed to update crops from \(url.lastPathComponent): \(error.localizedDescription)", file: url.lastPathComponent)
                }
            }
            
            if Task.isCancelled {
                throw CancellationError()
            }
        }
        
        try await cancellationToken?.value
    }
    
    func cancelUpdates() {
        cancellationToken?.cancel()
        progressContinuation?.finish()
    }
}
