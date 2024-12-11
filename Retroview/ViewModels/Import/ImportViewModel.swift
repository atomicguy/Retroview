//
//  ImportViewModel.swift
//  Retroview
//
//  Created by Adam Schuster on 12/9/24.
//

import SwiftData
import SwiftUI

@Observable
final class ImportViewModel {
    private(set) var progress: Progress?
    private(set) var error: AppError?
    private var importService: ImportService?
    
    func setError(_ error: AppError) {
        self.error = error
    }
    
    func clearError() {
        self.error = nil
    }
    
    func importFiles(at url: URL) async throws {
        clearError()
        
        do {
            guard try url.checkResourceIsReachable() else {
                setError(AppError.fileNotFound(url.path))
                return
            }
            
            let importService = await ImportService(
                modelContext: ModelContext.shared
            )
            
            for try await currentProgress in try await importService
                .importCards(from: url) {
                await MainActor.run {
                    self.progress = currentProgress
                }
            }
            
            await MainActor.run {
                self.progress = nil
            }
        } catch {
            await MainActor.run {
                if let appError = error as? AppError {
                    self.setError(appError)
                } else {
                    self.setError(AppError.importFailed(error))
                }
            }
        }
    }
}
