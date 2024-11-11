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

class StereoMaterialLoader: ObservableObject {
    @Published var material: ShaderGraphMaterial?
    @Published var status: LoadingStatus = .loading

    enum LoadingStatus {
        case loading
        case success
        case error(String)
    }

    func loadMaterial() async {
        do {
            self.material = try await ShaderGraphMaterial(
                named: "/Root/StereoMaterial",
                from: "StereoViewerScene",
                in: stereoViewerBundle
            )
            await MainActor.run {
                self.status = .success
            }
        } catch {
            print("Material loading error: \(error)")
            await MainActor.run {
                self.status = .error(error.localizedDescription)
            }
        }
    }
}

struct StereoMaterialView: View {
    @StateObject private var loader = StereoMaterialLoader()

    var body: some View {
        Group {
            switch self.loader.status {
            case .loading:
                ProgressView("Loading material...")
            case .success:
                Text("Material loaded successfully!")
                    .foregroundColor(.green)
            case .error(let message):
                VStack {
                    Text("Error loading material:")
                        .foregroundColor(.red)
                    Text(message)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .task {
            await self.loader.loadMaterial()
        }
    }
}

#Preview {
    StereoMaterialView()
}
