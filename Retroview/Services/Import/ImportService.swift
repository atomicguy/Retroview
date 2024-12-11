//
//  ImportService.swift
//  Retroview
//
//  Created by Adam Schuster on 12/9/24.
//

import Foundation
import SwiftData

actor ImportService {
    private let processCards: @MainActor (StereoCardDTO, Data?, Data?) async throws -> Void
    
    init(processCards: @escaping @MainActor (StereoCardDTO, Data?, Data?) async throws -> Void) {
        self.processCards = processCards
    }
    
    func importCards(from url: URL) async throws -> AsyncStream<Progress> {
        AsyncStream { continuation in
            Task {
                do {
                    let fileURLs = try FileManager.default.contentsOfDirectory(
                        at: url,
                        includingPropertiesForKeys: [.isRegularFileKey],
                        options: .skipsHiddenFiles
                    ).filter { $0.pathExtension.lowercased() == "json" }
                    
                    let progress = Progress(totalUnitCount: Int64(fileURLs.count))
                    continuation.yield(progress)
                    
                    for fileURL in fileURLs {
                        try await importCard(from: fileURL)
                        progress.completedUnitCount += 1
                        continuation.yield(progress)
                    }
                    
                    continuation.finish()
                } catch {
                    print("Import error: \(error)")
                    continuation.finish()
                }
            }
        }
    }
    
    private func importCard(from url: URL) async throws {
        let data = try Data(contentsOf: url)
        let cardDTO = try JSONDecoder().decode(StereoCardDTO.self, from: data)
        
        // Download images
        let frontImage = try? await downloadImage(id: cardDTO.imageIds.front)
        let backImage = try? await downloadImage(id: cardDTO.imageIds.back)
        
        // Process on MainActor
        try await self.processCards(cardDTO, frontImage, backImage)
    }
    
    private func downloadImage(id: String) async throws -> Data {
        let baseURL = "https://iiif-prod.nypl.org/index.php"
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "id", value: id),
            URLQueryItem(name: "t", value: "w")
        ]
        
        guard let url = components.url else {
            throw AppError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw AppError.imageDownloadFailed
        }
        
        return data
    }
}
