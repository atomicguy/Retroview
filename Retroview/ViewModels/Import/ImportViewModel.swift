//
//  ImportViewModel.swift
//  Retroview
//
//  Created by Adam Schuster on 12/9/24.
//

import SwiftUI

@Observable final class ImportViewModel {
    private(set) var progress: Progress?
    private(set) var error: Error?
    private let importService: ImportService
    
    init(importService: ImportService = .shared) {
        self.importService = importService
    }
    
    func importFiles(at url: URL) async {
        do {
            progress = Progress(totalUnitCount: 1)
            for try await currentProgress in await importService
                .importCards(from: url) {
                progress = currentProgress
            }
        } catch {
            self.error = error
        }
    }
}

