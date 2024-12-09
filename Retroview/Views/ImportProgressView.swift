//
//  ImportProgressView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/8/24.
//

import SwiftUI

struct ImportProgressView: View {
    let progress: Double
    let processed: Int
    let total: Int
    
    var body: some View {
        VStack {
            ProgressView(value: progress) {
                Text("Importing Cards...")
            } currentValueLabel: {
                Text("\(processed) of \(total)")
            }
            .padding()
            .background(.background) // Using SwiftUI's semantic color
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .shadow(radius: 2)
        }
        .frame(maxWidth: 300)
    }
}
