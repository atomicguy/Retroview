//
//  ThumbnailView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/1/24.
//

import SwiftData
import SwiftUI


struct ThumbnailView: View {
    let card: CardSchemaV1.StereoCard
    @State private var frontImage: CGImage?
    
    var body: some View {
        ZStack {
            if let image = frontImage {
                Image(decorative: image, scale: 1.0)
                    .resizable()
                    .scaledToFill()
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                ProgressView()
            }
        }
        .task {
            do {
                if let frontId = card.imageFrontId {
                    frontImage = try await ImageServiceFactory.shared.getService().loadThumbnail(
                        id: frontId, side: .front, maxSize: 400
                    )
                }
            } catch {
                print("Error loading thumbnail: \(error)")
            }
        }
    }
}

//struct ThumbnailView: View {
//    let card: CardSchemaV1.StereoCard
//    @StateObject private var viewModel: StereoCardViewModel
//
//    init(card: CardSchemaV1.StereoCard) {
//        self.card = card
//        _viewModel = StateObject(
//            wrappedValue: StereoCardViewModel(
//                stereoCard: card,
//                imageService: ImageServiceFactory.shared.getService()
//            )
//        )
//    }
//
//    var body: some View {
//        ZStack {
//            if let image = viewModel.frontCGImage {
//                Image(decorative: image, scale: 1.0)
//                    .resizable()
//                    .scaledToFill()
//                    .clipShape(RoundedRectangle(cornerRadius: 8))
//            } else {
//                ProgressView()
//            }
//        }
//        .task {
//            try? await viewModel.loadImage(forSide: "front")
//        }
//    }
//}
//
//#Preview {
//    let descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
//    let container = try! PreviewDataManager.shared.container()
//    let card = try! container.mainContext.fetch(descriptor).first!
//    
//    return ThumbnailView(card: card)
//        .frame(width: 400, height: 200)
//        .withPreviewData()
//}
