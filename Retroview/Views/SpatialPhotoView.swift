//
//  SpatialPhotoView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/28/24.
//

//import OSLog
//import QuickLook
//import SwiftUI
//
//struct SpatialPhotoView: View {
//    @Environment(\.imageLoader) private var imageLoader
//    @State private var selectedPreviewItem: URL?
//    @State private var isConverting = false
//    @State private var error: Error?
//    let card: CardSchemaV1.StereoCard
//
//    private let logger = Logger(
//        subsystem: "net.atompowered.retroview",
//        category: "SpatialPhotoView"
//    )
//
//    var body: some View {
//        VStack {
//            if isConverting {
//                ProgressView("Converting to spatial photo...")
//            } else if let error {
//                VStack(spacing: 8) {
//                    Label(
//                        error.localizedDescription,
//                        systemImage: "exclamationmark.triangle"
//                    )
//                    .foregroundStyle(.red)
//                    #if DEBUG
//                        Text(String(describing: error))
//                            .font(.caption)
//                            .foregroundStyle(.secondary)
//                    #endif
//                }
//            } else {
//                Button("View Spatial Photo") {
//                    Task {
//                        await createAndShowSpatialPhoto()
//                    }
//                }
//            }
//        }
//        .quickLookPreview($selectedPreviewItem)
//        .onAppear {
//            // Explicit logging
//            print("🔍 SpatialPhotoView onAppear")
//            logger.log("SpatialPhotoView appeared for card: \(self.card.uuid)")
//
//            // Log crop details
//            if let leftCrop = card.leftCrop {
//                print(
//                    "🖼️ Left Crop: x0=\(leftCrop.x0), y0=\(leftCrop.y0), x1=\(leftCrop.x1), y1=\(leftCrop.y1)"
//                )
//            }
//            if let rightCrop = card.rightCrop {
//                print(
//                    "🖼️ Right Crop: x0=\(rightCrop.x0), y0=\(rightCrop.y0), x1=\(rightCrop.x1), y1=\(rightCrop.y1)"
//                )
//            }
//        }
//    }
//
//    private func createAndShowSpatialPhoto() async {
//        logger.debug("Starting createAndShowSpatialPhoto")
//        print("🚀 Starting spatial photo creation")
//
//        guard !isConverting else { return }
//
//        isConverting = true
//        error = nil
//
//        do {
//            guard let imageLoader else {
//                print("❌ Missing image loader")
//                throw StereoError.missingImageLoader
//            }
//
//            print("📸 Attempting to load source image")
//            let sourceImage = try await imageLoader.loadImage(
//                for: card,
//                side: .front,
//                quality: .high
//            )
//
//            guard let sourceImage else {
//                print("❌ Failed to load source image")
//                throw StereoError.imageLoadFailed
//            }
//
//            print(
//                "🖌️ Source image loaded: \(sourceImage.width)x\(sourceImage.height)"
//            )
//
//            // Log crop details before conversion
//            if let leftCrop = card.leftCrop,
//                let rightCrop = card.rightCrop
//            {
//                print(
//                    """
//                    📏 Crop details:
//                    Left: (\(leftCrop.x0), \(leftCrop.y0)) -> (\(leftCrop.x1), \(leftCrop.y1))
//                    Right: (\(rightCrop.x0), \(rightCrop.y0)) -> (\(rightCrop.x1), \(rightCrop.y1))
//                    """)
//            }
//
//            let converter = StereoPhotoConverter()
//            print("🔄 Creating spatial photo...")
//            let url = try await converter.createTemporarySpatialPhoto(
//                from: card,
//                sourceImage: sourceImage
//            )
//
//            print("✅ Spatial photo created at: \(url.path)")
//
//            await MainActor.run {
//                selectedPreviewItem = url
//            }
//
//        } catch {
//            print("❌ Spatial photo creation failed: \(error)")
//            print("Detailed error: \(String(describing: error))")
//            logger.error(
//                "Failed to create spatial photo: \(error.localizedDescription)")
//            await MainActor.run {
//                self.error = error
//            }
//        }
//
//        await MainActor.run {
//            isConverting = false
//        }
//    }
//}
//
//#Preview {
//    // Configure logging
//    ImportLogger.configure(logLevel: .debug)
//
//    // Additional environment variable for logging
//    setenv("OS_ACTIVITY_MODE", "disable", 1)
//
//    // Find a card with required data for spatial photo creation
//    guard
//        let previewCard = PreviewDataManager.shared.singleCard({ card in
//            card.leftCrop != nil && card.rightCrop != nil
//                && card.imageFrontId != nil
//        })
//    else {
//        return Text("No suitable preview card found")
//    }
//
//    return SpatialPhotoView(card: previewCard)
//        .withPreviewStore()
//        .environment(\.imageLoader, CardImageLoader())
//        .padding()
//}

import SwiftUI
import QuickLook

struct SpatialPhotoViewComplex: View {
    let url: URL
    @State private var previewController: QLPreviewController?
    @State private var isPreviewReady = false
    @State private var error: Error?
    
    var body: some View {
        ZStack {
            if let error {
                errorView(error)
            } else if isPreviewReady {
                spatialPhotoPreview
            } else {
                ProgressView("Loading Spatial Photo...")
            }
        }
        .task {
            await prepareSpatialPhotoPreview()
        }
    }
    
    private var spatialPhotoPreview: some View {
        #if os(macOS)
        return QuickLookPreview(urls: [url])
            .frame(minWidth: 400, minHeight: 300)
        #else
        return QuickLookPreview(urls: [url])
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        #endif
    }
    
    private func prepareSpatialPhotoPreview() async {
        do {
            // Validate the file exists and is a valid HEIC
            guard FileManager.default.fileExists(atPath: url.path) else {
                throw SpatialPhotoError.fileNotFound
            }
            
            // Additional validation could be added here
            await MainActor.run {
                isPreviewReady = true
            }
        } catch {
            await MainActor.run {
                self.error = error
            }
        }
    }
    
    private func errorView(_ error: Error) -> some View {
        VStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text("Failed to Load Spatial Photo")
                .font(.headline)
            
            Text(error.localizedDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

// Custom error enum for spatial photo loading
enum SpatialPhotoError: LocalizedError {
    case fileNotFound
    case invalidFileFormat
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "Spatial photo file could not be found."
        case .invalidFileFormat:
            return "The file is not a valid spatial photo."
        }
    }
}

// Cross-platform QuickLook Preview Helper
struct QuickLookPreview: View {
    let urls: [URL]
    
    var body: some View {
        #if os(macOS)
        PreviewView(urls: urls)
        #else
        PreviewView(urls: urls)
            .edgesIgnoringSafeArea(.all)
        #endif
    }
}

// Platform-specific Preview View
struct PreviewView: UIViewControllerRepresentable {
    let urls: [URL]
    
    #if os(macOS)
    typealias NSViewControllerType = QLPreviewController
    
    func makeNSViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }
    
    func updateNSViewController(_ nsViewController: QLPreviewController, context: Context) {}
    #else
    typealias UIViewControllerType = QLPreviewController
    
    func makeUIViewController(context: Context) -> QLPreviewController {
        let controller = QLPreviewController()
        controller.dataSource = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: QLPreviewController, context: Context) {}
    #endif
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, QLPreviewControllerDataSource {
        var parent: PreviewView
        
        init(_ parent: PreviewView) {
            self.parent = parent
        }
        
        func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
            parent.urls.count
        }
        
        func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
            parent.urls[index] as QLPreviewItem
        }
    }
}

struct SpatialPhotoView: View {
    let url: URL
    
    var body: some View {
        Text("Opening photo...")
                    .onAppear {
                        PreviewApplication.open(urls: [url])
                    }
    }
}

// Preview with optional sample file
#Preview {
    if let url = Bundle.main.url(forResource: "sample", withExtension: "heic") {
        SpatialPhotoView(url: url)
            .frame(width: 400, height: 400)
    } else {
        Text("Sample HEIC file not found")
    }
}
