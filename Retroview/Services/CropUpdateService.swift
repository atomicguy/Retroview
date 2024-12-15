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
        
        // Fetch all cards and find the matching one
        let descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
        let cards = try modelContext.fetch(descriptor)
        
        print("📊 Found \(cards.count) total cards in database")
        print("🔢 First 5 card UUIDs in database:")
        cards.prefix(5).forEach { card in
            print("   • \(card.uuid.uuidString)")
        }
        
        // Debug: Check UUID formats
        let targetUUID = cropUpdate.uuid.lowercased()
        let existingUUIDs = cards.map { $0.uuid.uuidString.lowercased() }
        
        print("\n🎯 Looking for UUID: \(targetUUID)")
        print("📋 First 5 existing UUIDs:")
        existingUUIDs.prefix(5).forEach { uuid in
            print("   • \(uuid)")
            print("   • Matches target: \(uuid == targetUUID)")
        }
        
        guard let card = cards.first(where: {
            $0.uuid.uuidString.lowercased() == targetUUID
        }) else {
            print("❌ No matching card found")
            throw ImportError.processingError("Card not found: \(cropUpdate.uuid)")
        }
        
        print("✅ Found matching card!")
        
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
