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
        Group {
            if importManager.isImporting {
                Button {
                    importManager.cancelImport()
                } label: {
                    ZStack {
                        // Background circle
                        Circle()
                            .stroke(style: StrokeStyle(lineWidth: 3))
                            .foregroundStyle(.secondary.opacity(0.3))
                        
                        // Progress circle
                        Circle()
                            .trim(from: 0, to: CGFloat(calculateProgress()))
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
                .buttonStyle(.plain)
                .help(createTooltipText())
            }
        }
    }
    
    func calculateProgress() -> Double {
        guard
            importManager.isImporting,
            importManager.totalFileCount > 0
        else {
            logger.debug("Progress calculation: No active import")
            return 0
        }
        
        let progressValue = Double(importManager.importedFileCount) /
                            Double(importManager.totalFileCount)
        
        logger.debug("""
            Progress calculation: 
            \(importManager.importedFileCount) of \(importManager.totalFileCount) = \(progressValue)
            """)
        
        return progressValue
    }
    
    func createTooltipText() -> String {
        let percentage = Int(calculateProgress() * 100)
        return "\(importManager.importedFileCount) of \(importManager.totalFileCount) cards imported (\(percentage)%)"
    }
}
