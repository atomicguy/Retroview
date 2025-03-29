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
                // Log more detailed error information
                let fileList = (try? FileManager.default.contentsOfDirectory(
                    at: url,
                    includingPropertiesForKeys: nil
                )) ?? []
                
                let fileNames = fileList.map { $0.lastPathComponent }
                
                ImportLogger.log(
                    .error,
                    """
                    Crop update failed for \(url.lastPathComponent):
                    - Error: \(error.localizedDescription)
                    - Files in directory: \(fileNames)
                    """,
                    file: url.lastPathComponent
                )
                
                // Optionally rethrow or handle the error
                throw error
            }
        }
    }
    
    private func updateCrops(from url: URL) async throws {
        // Get all JSON files in the directory
        let jsonFiles = try FileManager.default
            .contentsOfDirectory(
                at: url,
                includingPropertiesForKeys: [.isRegularFileKey],
                options: .skipsHiddenFiles
            )
            .filter { $0.pathExtension.lowercased() == "json" }
        
        // Log found JSON files
        print("Found JSON files: \(jsonFiles.map { $0.lastPathComponent })")
        
        // If no JSON files found, throw a descriptive error
        guard !jsonFiles.isEmpty else {
            throw ImportError.noJsonFiles(directory: url.lastPathComponent)
        }
        
        // Process each JSON file
        for fileURL in jsonFiles {
            let data = try Data(contentsOf: fileURL)
            let cropUpdate = try JSONDecoder().decode(CropUpdateJSON.self, from: data)
            
            guard let card = try await findExistingCard(uuid: cropUpdate.uuid) else {
                ImportLogger.log(
                    .warning,
                    "Card not found for UUID: \(cropUpdate.uuid)",
                    file: fileURL.lastPathComponent
                )
                continue
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
            
            ImportLogger.log(
                .info,
                "Updated crops for card: \(cropUpdate.uuid)",
                file: fileURL.lastPathComponent
            )
        }
    }
    
    private func findExistingCard(uuid: String) async throws -> CardSchemaV1.StereoCard? {
        guard let cardUUID = UUID(uuidString: uuid.lowercased()) else { return nil }
        let descriptor = FetchDescriptor(predicate: ModelPredicates.Card.withUUID(cardUUID))
        return try modelContext.fetch(descriptor).first
    }
}
