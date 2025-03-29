//
//  BackgroundProgressIndicator.swift
//  Retroview
//
//  Created by Adam Schuster on 12/21/24.
//

import SwiftUI
import OSLog

private let logger = Logger(
    subsystem: "net.atompowered.retroview",
    category: "BackgroundProgress"
)

struct BackgroundProgressIndicator: View {
    let isProcessing: Bool
    let processedCount: Int
    let totalCount: Int
    let onCancel: () -> Void
    
    var body: some View {
        Button {
            onCancel()
        } label: {
            ZStack {
                // Background circle
                Circle()
                    .stroke(style: StrokeStyle(lineWidth: 3))
                    .foregroundStyle(.secondary.opacity(0.3))
                
                // Progress circle
                Circle()
                    .trim(from: 0, to: calculateProgress())
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
    
    private func calculateProgress() -> Double {
        guard totalCount > 0 else { return 0 }
        return Double(processedCount) / Double(totalCount)
    }
    
    private func createTooltipText() -> String {
        let percentage = Int(calculateProgress() * 100)
        return "\(processedCount) of \(totalCount) processed (\(percentage)%)"
    }
}
