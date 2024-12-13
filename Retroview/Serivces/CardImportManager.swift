//
//  CardImportManager.swift
//  Retroview
//
//  Created by Adam Schuster on 12/11/24.
//

import SwiftData
import Foundation

@MainActor
final class CardImportManager: ObservableObject {
    private let importService: MODSImportService
    
    @Published private(set) var importProgress: Progress
    @Published private(set) var isImporting: Bool = false
    
    init(modelContext: ModelContext) {
        self.importService = MODSImportService(modelContext: modelContext)
        self.importProgress = Progress()
    }
    
    func importCards(from urls: [URL]) async throws {
        guard !isImporting else { return }
        
        isImporting = true
        defer { isImporting = false }
        
        importProgress = Progress(totalUnitCount: Int64(urls.count))
        importProgress.completedUnitCount = 0
        
        for url in urls {
            do {
                guard url.startAccessingSecurityScopedResource() else {
                    throw ImportError.securityScopedResourceAccessDenied
                }
                defer { url.stopAccessingSecurityScopedResource() }
                
                let data = try Data(contentsOf: url)
                _ = try await importService.importCard(from: data)
                
                importProgress.completedUnitCount += 1
            } catch {
                print("Error importing card from \(url.lastPathComponent): \(error)")
                // Continue with next file even if one fails
            }
        }
    }
}

// MARK: - Import Progress
extension CardImportManager {
    var progress: Double {
        guard importProgress.totalUnitCount > 0 else { return 0 }
        return Double(importProgress.completedUnitCount) / Double(importProgress.totalUnitCount)
    }
    
    var progressDescription: String {
        "\(importProgress.completedUnitCount)/\(importProgress.totalUnitCount) cards imported"
    }
}

// MARK: - Error Types
enum ImportError: LocalizedError {
    case securityScopedResourceAccessDenied
    
    var errorDescription: String? {
        switch self {
        case .securityScopedResourceAccessDenied:
            return "Access to the selected file was denied"
        }
    }
}
