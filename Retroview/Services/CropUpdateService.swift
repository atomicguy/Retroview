//
//  CropUpdateService.swift
//  Retroview
//
//  Created by Adam Schuster on 12/14/24.
//

import Foundation
import SwiftData

@Observable @MainActor
final class CropUpdateService {
    private(set) var currentProgress: Progress?
    private(set) var isProcessing = false
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func updateCropsInBatch(from urls: [URL]) async throws {
        isProcessing = true
        defer { isProcessing = false }
        
        let progress = Progress(totalUnitCount: Int64(urls.count))
        currentProgress = progress
        
        for url in urls {
            try Task.checkCancellation()
            
            do {
                try await updateCrops(from: url)
                progress.completedUnitCount += 1
            } catch {
                ImportLogger.log(.error, "Failed to update crops: \(error.localizedDescription)", file: url.lastPathComponent)
            }
        }
    }
    
    private func updateCrops(from url: URL) async throws {
        let data = try Data(contentsOf: url)
        let cropUpdate = try JSONDecoder().decode(CropUpdateJSON.self, from: data)
        
        guard let card = try await findExistingCard(uuid: cropUpdate.uuid) else {
            ImportLogger.log(.warning, "Card not found", file: url.lastPathComponent)
            return
        }
        
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
        
        card.leftCrop = leftCrop
        card.rightCrop = rightCrop
        
        try modelContext.save()
        ImportLogger.log(.info, "Updated crops for card: \(cropUpdate.uuid)")
    }
    
    private func findExistingCard(uuid: String) async throws -> CardSchemaV1.StereoCard? {
        guard let cardUUID = UUID(uuidString: uuid.lowercased()) else { return nil }
        let descriptor = FetchDescriptor(predicate: ModelPredicates.Card.withUUID(cardUUID))
        return try modelContext.fetch(descriptor).first
    }
}
