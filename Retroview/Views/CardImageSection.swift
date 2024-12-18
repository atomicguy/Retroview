//
//  CardImageSection.swift
//  Retroview
//
//  Created by Adam Schuster on 12/17/24.
//

import SwiftUI

struct CardImageSection: View {
    let card: CardSchemaV1.StereoCard
    let side: CardSide
    let title: String
    
    @State private var image: CGImage?
    @State private var loadingError = false
    @State private var showingDetail = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Button {
                showingDetail = true
            } label: {
                Group {
                    if let image {
                        Image(decorative: image, scale: 1.0)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    } else {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(.gray.opacity(0.1))
                            .overlay {
                                if loadingError {
                                    Label("Failed to load", systemImage: "exclamationmark.triangle")
                                        .foregroundStyle(.secondary)
                                } else {
                                    ProgressView()
                                }
                            }
                            .aspectRatio(2/1, contentMode: .fit)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
        }
        .sheet(isPresented: $showingDetail) {
            NavigationStack {
                ZoomableImageView(image: image)
                    .navigationTitle("\(side.rawValue.capitalized) View")
//                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                showingDetail = false
                            }
                        }
                    }
            }
        }
        .task {
            do {
                image = try await card.loadImage(side: side, quality: .standard)
            } catch {
                loadingError = true
            }
        }
    }
}

struct ZoomableImageView: View {
    let image: CGImage?
    @State private var scale = 1.0
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView([.horizontal, .vertical]) {
                if let image {
                    Image(decorative: image, scale: 1.0)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(
                            width: geometry.size.width * scale,
                            height: geometry.size.height * scale
                        )
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .toolbar {
                ToolbarItem {
                    HStack {
                        Button { scale = max(1.0, scale - 0.25) } label: {
                            Label("Zoom Out", systemImage: "minus.magnifyingglass")
                        }
                        .disabled(scale <= 1.0)
                        
                        Button { scale = min(4.0, scale + 0.25) } label: {
                            Label("Zoom In", systemImage: "plus.magnifyingglass")
                        }
                        .disabled(scale >= 4.0)
                    }
                }
            }
        }
    }
}
