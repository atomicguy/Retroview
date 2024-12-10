//
//  ImportProgressView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/9/24.
//

import SwiftUI

struct ImportProgressView: View {
    let progress: Progress
    
    private var percentage: Double {
        Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)
            
            VStack(spacing: 8) {
                ProgressView(value: percentage) {
                    Text("Importing cards...")
                }
                
                HStack {
                    Text("\(progress.completedUnitCount) of \(progress.totalUnitCount)")
                        .monospacedDigit()
                    Text("•")
                    Text("\(Int(percentage * 100))%")
                        .monospacedDigit()
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            .frame(maxWidth: 300)
        }
    }
}
