//
//  CardContentView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/9/24.
//

import SwiftData
import SwiftUI

struct CardContentView: View {
    let card: CardSchemaV1.StereoCard
    @State private var viewModel: CardViewModel
    @State private var error: AppError?
    
    init(card: CardSchemaV1.StereoCard) {
        self.card = card
        _viewModel = State(initialValue: CardViewModel(card: card))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(card.titlePick?.text ?? card.titles.first?.text ?? "Untitled")
                    .font(.title)
                    .frame(maxWidth: .infinity)
                
                CardImageView(card: card, side: .front)
                    .overlay {
                        if viewModel.isLoadingFront {
                            ProgressView()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(.ultraThinMaterial)
                        }
                    }
                
                OrnamentalDivider()
                
                CardMetadataView(card: card)
                
                OrnamentalDivider()
                
                Text("Reverse")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                
                CardImageView(card: card, side: .back)
                    .overlay {
                        if viewModel.isLoadingBack {
                            ProgressView()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .background(.ultraThinMaterial)
                        }
                    }
            }
            .padding()
        }
        .handleError($error) {
            // Retry loading images
            Task {
                await viewModel.loadImage(for: .front)
                await viewModel.loadImage(for: .back)
            }
        }
        .onChange(of: viewModel.error) { _, newError in
            if let newError {
                error = newError
                viewModel.clearError()
            }
        }
    }
}
