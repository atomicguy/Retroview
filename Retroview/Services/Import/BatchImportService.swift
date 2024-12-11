//
//  BatchImportService.swift
//  Retroview
//
//  Created by Adam Schuster on 12/9/24.
//

import Foundation

@Observable final class BatchImportService {
    private var importService: ImportService?
    private var currentTask: Task<Void, Error>?
    
    func startImport(from url: URL) -> AsyncStream<Progress> {
        AsyncStream { continuation in
            currentTask = Task {
                let service = await ImageServiceFactory.shared.getService()
                for await progress in await service.importCards(from: url) {
                    continuation.yield(progress)
                }
                continuation.finish()
            }
        }
    }
    
    func cancel() {
        currentTask?.cancel()
        currentTask = nil
    }
}
