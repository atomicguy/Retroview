//
//  LoadingIndicator.swift
//  Retroview
//
//  Created by Adam Schuster on 12/9/24.
//

import SwiftUI

struct LoadingIndicator: View {
    let message: String
    
    var body: some View {
        VStack(spacing: 12) {
            ProgressView()
                .controlSize(.large)
            Text(message)
                .foregroundStyle(.secondary)
        }
    }
}

