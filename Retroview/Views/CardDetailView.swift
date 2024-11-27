//
//  CardDetails.swift
//  Retroview
//
//  Created by Adam Schuster on 5/27/24.
//

import SwiftData
import SwiftUI

struct CardDetailView: View {
    @Bindable var card: CardSchemaV1.StereoCard
    @StateObject private var viewModel: StereoCardViewModel
    @State private var showingStereoView = false

    init(card: CardSchemaV1.StereoCard) {
        self.card = card
        _viewModel = StateObject(
            wrappedValue: StereoCardViewModel(stereoCard: card))
    }

    var displayTitle: TitleSchemaV1.Title {
        card.titlePick ?? card.titles.first
            ?? TitleSchemaV1.Title(text: "Unknown")
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text(displayTitle.text)
                    .font(.system(.title, design: .serif))
                    .frame(maxWidth: .infinity, alignment: .center)

                HStack(alignment: .center) {
                    StereoCardImageView(viewModel: viewModel, side: "front")
                        .frame(width: 400, height: 200)
                    StereoCardImageView(viewModel: viewModel, side: "back")
                        .frame(width: 400, height: 200)
                }
                .frame(maxWidth: .infinity, alignment: .center)

                #if os(visionOS)
                    Button(action: { showingStereoView = true }) {
                        StereoPreviewButton(viewModel: viewModel)
                    }
                    .fullScreenCover(isPresented: $showingStereoView) {  // Changed from .sheet to .fullScreenCover
                        NavigationStack {
                            StereoView(card: card)
                                .navigationTitle(displayTitle.text)
                                .navigationBarTitleDisplayMode(.inline)
                                .toolbar {
                                    ToolbarItem(placement: .cancellationAction)
                                    {
                                        Button("Close") {
                                            showingStereoView = false
                                        }
                                    }
                                }
                        }
                        .presentationBackground(.clear)
                    }
                #else
                    Button(action: { showingStereoView = true }) {
                        StereoPreviewButton(viewModel: viewModel)
                    }
                    .sheet(isPresented: $showingStereoView) {
                        StereoView(card: card)
                            .frame(minWidth: 800, minHeight: 600)
                    }
                #endif

                MetadataView(card: card)
            }
            .padding()
        }
    }
}

// Break out the stereo preview button for better organization
struct StereoPreviewButton: View {
    @ObservedObject var viewModel: StereoCardViewModel

    var body: some View {
        ZStack {
            if let frontImage = viewModel.frontCGImage {
                Image(decorative: frontImage, scale: 1.0)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .overlay(Rectangle().fill(Color.black.opacity(0.3)))
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
            }

            VStack {
                Image(systemName: "view.3d")
                    .font(.largeTitle)
                    .foregroundColor(.white)

                Text("View in Stereo")
                    .foregroundColor(.white)
                    .font(.headline)
            }
            .padding()
            .background(Color.black.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

// Break out the metadata view for better organization
struct MetadataView: View {
    let card: CardSchemaV1.StereoCard

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(card.uuid.uuidString)
                .font(.system(.caption, design: .serif))

            if !card.authors.isEmpty {
                metadataSection("Authors:", items: card.authors.map(\.name))
            }

            if !card.subjects.isEmpty {
                metadataSection("Subjects:", items: card.subjects.map(\.name))
            }

            if !card.dates.isEmpty {
                metadataSection("Dates:", items: card.dates.map(\.text))
            }
        }
        .font(.system(.body, design: .serif))
    }

    private func metadataSection(_ title: String, items: [String]) -> some View
    {
        HStack(alignment: .top) {
            Text(title)
            VStack(alignment: .leading) {
                ForEach(items, id: \.self) { item in
                    Text(item)
                }
            }
        }
    }
}

private struct MetadataSection: View {
    let title: String
    let items: [String]

    var body: some View {
        HStack(alignment: .top) {
            Text(title)
            VStack(alignment: .leading) {
                ForEach(items, id: \.self) { item in
                    Text(item)
                }
            }
        }
    }
}

#Preview {
    CardDetailView(card: PreviewHelper.shared.previewCard)
        .modelContainer(PreviewHelper.shared.modelContainer)
}
