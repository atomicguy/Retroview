//
//  StereoMaterialLoader.swift
//  Retroview
//
//  Created by Adam Schuster on 11/10/24.
//

import Foundation
import RealityKit
import StereoViewer
import SwiftUI

// MARK: - Custom Error Type

enum MaterialLoadingError: LocalizedError {
    case failedToLoadMaterial(String)

    var errorDescription: String? {
        switch self {
        case let .failedToLoadMaterial(message):
            "Failed to load material: \(message)"
        }
    }
}

// MARK: - StereoMaterialLoader

@MainActor
class StereoMaterialLoader: ObservableObject {
    @Published var material: ShaderGraphMaterial?
    @Published var status: LoadingStatus = .loading

    enum LoadingStatus {
        case loading
        case success
        case error(MaterialLoadingError)
    }

    func loadMaterial() async {
        do {
            // Load the material asynchronously
            let loadedMaterial = try await ShaderGraphMaterial(
                named: "/Root/StereoMaterial",
                from: "StereoViewerScene",
                in: stereoViewerBundle
            )
            material = loadedMaterial
            status = .success
        } catch {
            status = .error(.failedToLoadMaterial(error.localizedDescription))
        }
    }
}

// MARK: - StereoMaterialView

struct StereoMaterialView: View {
    @StateObject private var loader = StereoMaterialLoader()

    var body: some View {
        Group {
            switch loader.status {
            case .loading:
                ProgressView("Loading material...")
            case .success:
                Text("Material loaded successfully!")
                    .foregroundColor(.green)
            case let .error(error):
                VStack {
                    Text("Error loading material:")
                        .foregroundColor(.red)
                    Text(error.localizedDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .task {
            await loader.loadMaterial()
        }
        .onDisappear {
            // Cancel tasks if necessary (future enhancement)
        }
    }
}

//#Preview {
//    StereoMaterialView()
//        .withPreviewData()
//}
