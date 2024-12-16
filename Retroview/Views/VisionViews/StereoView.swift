//
//  StereoView.swift
//  Retroview
//
//  Created by Adam Schuster on 10/20/24.

import SwiftData
import SwiftUI

#if os(visionOS)
    import RealityKit
    import StereoViewer

    struct StereoView: View {
        let card: CardSchemaV1.StereoCard
        @Environment(\.dismiss) private var dismiss
        @StateObject private var coordinator = StereoViewCoordinator()
        @StateObject private var viewModel: StereoCardViewModel
        @StateObject private var materialLoader = StereoMaterialLoader()
        @State private var content: RealityViewContent?
        @State private var isReady = false

        init(card: CardSchemaV1.StereoCard) {
            self.card = card
            _viewModel = StateObject(
                wrappedValue: StereoCardViewModel(stereoCard: card))
        }

        var body: some View {
            GeometryReader { geometry in
                ZStack {
                    if isReady {
                        mainView(geometry: geometry)
                            .transition(.opacity)
                    } else {
                        loadingView
                            .transition(.opacity)
                    }
                }
                .animation(.easeInOut, value: isReady)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .task {
                do {
                    await materialLoader.loadMaterial()
                    coordinator.stereoMaterial = materialLoader.material
                    try await viewModel.loadImage(forSide: "front")
                    withAnimation { isReady = true }
                } catch {
                    print("Error loading stereo view: \(error)")
                }
            }
        }

        private func mainView(geometry _: GeometryProxy) -> some View {
            RealityView { content in
                self.content = content
            } update: { content in
                let contentCopy = content
                Task { @MainActor in
                    if let image = viewModel.frontCGImage {
                        do {
                            try await coordinator.updateContent(
                                content: contentCopy,
                                sourceImage: image,
                                leftCrop: card.leftCrop,
                                rightCrop: card.rightCrop
                            )
                        } catch {
                            print("Error updating reality view: \(error)")
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }

        private var loadingView: some View {
            VStack(spacing: 16) {
                ProgressView()
                    .controlSize(.large)
                Text("Loading stereo view...")
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
#endif

//// MARK: - Preview Support
//
//#Preview("Stereo View") {
//    let descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
//    let container = try! PreviewDataManager.shared.container()
//    let card = try! container.mainContext.fetch(descriptor).first!
//    
//    return StereoView(card: card)
//        .withPreviewData()
//}
