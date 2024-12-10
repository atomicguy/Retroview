//
//  PreviewDataManager.swift
//  Retroview
//
//  Created by Adam Schuster on 12/7/24.
//

import SwiftData
import SwiftUI

@MainActor final class PreviewDataManager {
    static let shared = PreviewDataManager()
    
    var container: ModelContainer?
    private let fileManager = FileManager.default
    
    private init() {}
    
    func getContainer() throws -> ModelContainer {
        if let existing = container {
            return existing
        }
        
        container = try StoreManager.shared.createContainer()
        return container!
    }
    
    func populateData() async throws {
        let context = try getContainer().mainContext
        
        guard try context.fetch(FetchDescriptor<CardSchemaV1.StereoCard>()).isEmpty else {
            return
        }
        
        try await loadSampleData(into: context)
    }
    
    private func loadSampleData(into context: ModelContext) async throws {
        // Implementation details...
    }
}
