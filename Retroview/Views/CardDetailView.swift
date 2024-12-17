//
//  CardDetailView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/15/24.
//

import SwiftData
import SwiftUI

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(
        proposal: ProposedViewSize, subviews: Subviews, cache: inout ()
    ) -> CGSize {
        let sizes = subviews.map { $0.sizeThatFits(.unspecified) }
        var width: CGFloat = 0
        var height: CGFloat = 0
        var lineWidth: CGFloat = 0
        var lineHeight: CGFloat = 0

        for size in sizes {
            if lineWidth + size.width > (proposal.width ?? .infinity) {
                // Start new line
                width = max(width, lineWidth)
                height += lineHeight + spacing
                lineWidth = size.width + spacing
                lineHeight = size.height
            } else {
                lineWidth += size.width + spacing
                lineHeight = max(lineHeight, size.height)
            }
        }

        return CGSize(
            width: max(width, lineWidth),
            height: height + lineHeight
        )
    }

    func placeSubviews(
        in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews,
        cache: inout ()
    ) {
        var x = bounds.minX
        var y = bounds.minY
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if x + size.width > bounds.maxX {
                // Start new line
                x = bounds.minX
                y += lineHeight + spacing
                lineHeight = 0
            }

            subview.place(
                at: CGPoint(x: x, y: y),
                proposal: .unspecified
            )

            x += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}

// MARK: - Card Detail View
struct CardDetailView: View {
    let card: CardSchemaV1.StereoCard

    @State private var frontImage: CGImage?
    @State private var backImage: CGImage?
    @State private var loadingError: CardSide?

    // Track visibility for image loading
    @State private var isViewVisible = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Front image section
                Group {
                    Text("Front")
                        .font(.headline)
                        .foregroundStyle(.secondary)

                    imageSection(image: frontImage, side: .front)
                }

                // Metadata sections
                metadataSections
                    .padding(.horizontal, 4)

                // Back image section if available
                if card.imageBackId != nil {
                    Divider()

                    Group {
                        Text("Back")
                            .font(.headline)
                            .foregroundStyle(.secondary)

                        imageSection(image: backImage, side: .back)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(card.titlePick?.text ?? "Untitled Card")
        // Load images when view becomes visible
        .task(id: isViewVisible) {
            guard isViewVisible else { return }
            await loadImages()
        }
        .onAppear { isViewVisible = true }
        .onDisappear { isViewVisible = false }
    }

    private func loadImages() async {
        // Load front image at standard quality
        do {
            frontImage = try await card.loadImage(
                side: .front, quality: .standard)
        } catch {
            loadingError = .front
        }

        // Load back image if available
        if card.imageBackId != nil {
            do {
                backImage = try await card.loadImage(
                    side: .back, quality: .standard)
            } catch {
                loadingError = .back
            }
        }
    }

    @ViewBuilder
    private func imageSection(image: CGImage?, side: CardSide) -> some View {
        if let image {
            Image(decorative: image, scale: 1.0)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .frame(maxWidth: .infinity)
        } else {
            imagePlaceholder(side: side)
        }
    }

    @ViewBuilder
    private func imagePlaceholder(side: CardSide) -> some View {
        let hasError = loadingError == side
        let hasImageId =
            side == .front ? card.imageFrontId != nil : card.imageBackId != nil

        RoundedRectangle(cornerRadius: 16)
            .fill(.gray.opacity(0.2))
            .aspectRatio(2, contentMode: .fit)
            .overlay {
                if hasError {
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle")
                        Text("Failed to load image")
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                } else if hasImageId {
                    ProgressView()
                } else {
                    Image(systemName: "photo")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                }
            }
    }

    private var metadataSections: some View {
        Group {
            // Titles section
            if !card.titles.isEmpty {
                metadataSection("Titles") {
                    ForEach(card.titles, id: \.text) { title in
                        Text(title.text)
                            .font(
                                title.text == card.titlePick?.text
                                    ? .body.bold() : .body)
                    }
                }
            }

            // Subjects section
            if !card.subjects.isEmpty {
                metadataSection("Subjects") {
                    FlowLayout(spacing: 8) {
                        ForEach(card.subjects, id: \.name) { subject in
                            Text(subject.name)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.secondary.opacity(0.2))
                                .clipShape(Capsule())
                        }
                    }
                }
            }

            // Authors section
            if !card.authors.isEmpty {
                metadataSection("Authors") {
                    ForEach(card.authors, id: \.name) { author in
                        Text(author.name)
                    }
                }
            }

            // Dates section
            if !card.dates.isEmpty {
                metadataSection("Dates") {
                    ForEach(card.dates, id: \.text) { date in
                        Text(date.text)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func metadataSection<Content: View>(
        _ title: String, @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            content()
        }
    }
}
