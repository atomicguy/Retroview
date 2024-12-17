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
    
    // Split the view into focused components
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Image sections
                CardImageSection(
                    card: card,
                    side: .front,
                    title: "Front"
                )
                
                // Metadata sections using relationships
                CardMetadataSection(card: card)
                
                // Back image if available
                if card.imageBackId != nil {
                    Divider()
                    CardImageSection(
                        card: card,
                        side: .back,
                        title: "Back"
                    )
                }
            }
            .padding()
        }
        .navigationTitle(card.titlePick?.text ?? "Untitled Card")
    }
}

// Break out image handling to its own view
private struct CardImageSection: View {
    let card: CardSchemaV1.StereoCard
    let side: CardSide
    let title: String
    
    @State private var image: CGImage?
    @State private var loadingError = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.secondary)
            
            if let image {
                Image(decorative: image, scale: 1.0)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                imagePlaceholder
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
    
    private var imagePlaceholder: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(.gray.opacity(0.2))
            .aspectRatio(2, contentMode: .fit)
            .overlay {
                if loadingError {
                    VStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle")
                        Text("Failed to load image")
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                } else {
                    ProgressView()
                }
            }
    }
}

// Break out metadata into its own view
private struct CardMetadataSection: View {
    let card: CardSchemaV1.StereoCard
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Titles
            if !card.titles.isEmpty {
                metadataGroup("Titles") {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(card.titles, id: \.text) { title in
                            Text(title.text)
                                .font(title == card.titlePick ? .body.bold() : .body)
                        }
                    }
                }
            }
            
            // Subjects with FlowLayout
            if !card.subjects.isEmpty {
                metadataGroup("Subjects") {
                    FlowLayout(spacing: 8) {
                        ForEach(card.subjects, id: \.name) { subject in
                            NavigationLink(value: subject) {
                                Text(subject.name)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(.secondary.opacity(0.2))
                                    .clipShape(Capsule())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            
            // Authors
            if !card.authors.isEmpty {
                metadataGroup("Authors") {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(card.authors, id: \.name) { author in
                            NavigationLink(value: author) {
                                Text(author.name)
                            }
                        }
                    }
                }
            }
            
            // Dates
            if !card.dates.isEmpty {
                metadataGroup("Dates") {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(card.dates, id: \.text) { date in
                            Text(date.text)
                        }
                    }
                }
            }
        }
    }
    
    private func metadataGroup<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            content()
        }
    }
}
