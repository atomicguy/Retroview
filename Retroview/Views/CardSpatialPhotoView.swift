////
////  CardSpatialPhotoView.swift
////  Retroview
////
////  Created by Adam Schuster on 12/28/24.
////
//
//import SwiftUI
//
//struct CardSpatialPhotoView: View {
//    @Environment(\.imageLoader) private var imageLoader
//    let card: CardSchemaV1.StereoCard
//    
//    @State private var photoManager = SpatialPhotoManager()
//    @State private var sourceImage: CGImage?
//    @State private var isLoadingImage = false
//    @State private var loadError: Error?
//    
//    var body: some View {
//        ZStack {
//            if let error = photoManager.error ?? loadError {
//                errorView(error)
//            } else if photoManager.isConverting || isLoadingImage {
//                loadingView
//            } else if let url = photoManager.spatialPhotoURL {
//                SpatialPhotoView(url: url)
//            } else {
//                ContentUnavailableView("No Image",
//                    systemImage: "photo.badge.exclamationmark")
//            }
//        }
//        .task {
//            await loadAndConvert()
//        }
//    }
//    
//    private func loadAndConvert() async {
//        guard !isLoadingImage, let imageLoader else { return }
//        
//        isLoadingImage = true
//        defer { isLoadingImage = false }
//        
//        do {
//            let image = try await imageLoader.loadImage(
//                for: card,
//                side: .front,
//                quality: .high
//            )
//            
//            if let image {
//                await photoManager.createSpatialPhoto(from: card, sourceImage: image)
//            }
//        } catch {
//            loadError = error
//        }
//    }
//    
//    private var loadingView: some View {
//        ProgressView()
//            .controlSize(.large)
//    }
//    
//    private func errorView(_ error: Error) -> some View {
//        VStack(spacing: 8) {
//            Image(systemName: "exclamationmark.triangle")
//                .font(.largeTitle)
//                .foregroundStyle(.red)
//            Text("Error")
//                .font(.headline)
//            Text(error.localizedDescription)
//                .font(.caption)
//                .multilineTextAlignment(.center)
//                .foregroundStyle(.secondary)
//        }
//        .padding()
//    }
//}
//
//#Preview {
//    CardPreviewContainer { card in
//        CardSpatialPhotoView(card: card)
//            .frame(width: 400, height: 400)
//    }
//}
