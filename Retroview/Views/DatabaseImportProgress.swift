//
//  DatabaseImportProgress.swift
//  Retroview
//
//  Created by Adam Schuster on 12/20/24.
//

import SwiftUI

struct DatabaseImportProgress: View {
    let phase: ImportPhase
    let progress: Double
    
    enum ImportPhase {
        case decompressing
        case importing(processed: Int, total: Int)
        case completed
        
        var message: String {
            switch self {
            case .decompressing:
                "Decompressing database..."
            case .importing(let processed, let total):
                "Importing \(processed) of \(total) cards..."
            case .completed:
                "Import completed!"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            ProgressView()
                .controlSize(.large)
            
            Text(phase.message)
                .font(.headline)
            
            if case .importing = phase {
                ProgressView(value: progress)
                    .frame(width: 200)
            }
        }
        .frame(width: 300, height: 200)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
