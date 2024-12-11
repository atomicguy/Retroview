//
//  ErrorView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/9/24.
//

import SwiftUI

struct ErrorView: View {
    let error: AppError
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Import Failed")
                .font(.headline)
                .foregroundColor(.red)
            
            Text(error.localizedDescription)
                .font(.subheadline)
                .multilineTextAlignment(.center)
            
            Button("Dismiss") {
                onDismiss()
            }
            .padding(.top)
        }
        .padding()
        .background(Color.red.opacity(0.1))
        .cornerRadius(8)
    }
}
