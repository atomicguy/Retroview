//
//  ImportProgressIndicator.swift
//  Retroview
//
//  Created by Adam Schuster on 12/21/24.
//

import SwiftUI
import OSLog

private let logger = Logger(
    subsystem: "net.atompowered.retroview",
    category: "ImportProgress"
)

struct ImportProgressIndicator: View {
    @Bindable var importManager: BackgroundImportManager
    
    var body: some View {
        if importManager.isImporting {
            Button {
                importManager.cancelImport()
            } label: {
                ImportProgressCircle(
                    progress: calculateProgress(),
                    processedCount: importManager.importedFileCount,
                    totalCount: importManager.totalFileCount
                )
            }
            .buttonStyle(.plain)
            .help(createTooltipText())
        }
    }
    
    private func calculateProgress() -> Double {
        guard importManager.totalFileCount > 0 else { return 0 }
        return Double(importManager.importedFileCount) / Double(importManager.totalFileCount)
    }
    
    private func createTooltipText() -> String {
        let percentage = Int(calculateProgress() * 100)
        return "\(importManager.importedFileCount) of \(importManager.totalFileCount) files imported (\(percentage)%)"
    }
}

// MARK: - Progress Circle
struct ImportProgressCircle: View {
    let progress: Double
    let processedCount: Int
    let totalCount: Int
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(style: StrokeStyle(lineWidth: 3))
                .foregroundStyle(.secondary.opacity(0.3))
            
            // Progress circle
            Circle()
                .trim(from: 0, to: CGFloat(progress))
                .stroke(style: StrokeStyle(
                    lineWidth: 3,
                    lineCap: .round
                ))
                .foregroundStyle(.blue)
                .rotationEffect(.degrees(-90))
            
            // Cancel icon
            Image(systemName: "xmark")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
        }
        .frame(width: 24, height: 24)
    }
}
