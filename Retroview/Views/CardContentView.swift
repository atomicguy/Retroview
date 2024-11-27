//
//  CardContentView.swift
//  Retroview
//
//  Created by Adam Schuster on 11/25/24.
//

import SwiftData
import SwiftUI

// MARK: - Typography Style Extension

extension Font {
    fileprivate static let cardTitle = Font.system(.title, design: .serif)
    fileprivate static let cardHeadline = Font.system(.headline, design: .serif)
    fileprivate static let cardSubheadline = Font.system(
        .title2, design: .serif)
    fileprivate static let cardBody = Font.system(.body, design: .serif)
    fileprivate static let cardCaption = Font.system(.caption, design: .serif)
}

// MARK: - Decorative Elements

private struct OrnamentalDivider: View {
    var body: some View {
        HStack {
            Image(systemName: "laurel.leading")
                .foregroundStyle(.secondary.opacity(0.5))

            Rectangle()
                .frame(height: 1)
                .foregroundStyle(.secondary.opacity(0.3))

            Image(systemName: "laurel.trailing")
                .foregroundStyle(.secondary.opacity(0.5))
        }
        .padding(.vertical, 6)
    }
}

private struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.cardSubheadline.smallCaps())
            .fontWeight(.regular)
            .foregroundStyle(.secondary)
    }
}

// MARK: - Main View

struct CardContentView: View {
    @Bindable var card: CardSchemaV1.StereoCard
    @StateObject private var viewModel: StereoCardViewModel

    init(card: CardSchemaV1.StereoCard) {
        self.card = card
        _viewModel = StateObject(
            wrappedValue: StereoCardViewModel(stereoCard: card))
    }

    var selectedTitle: String {
        card.titlePick?.text ?? card.titles.first?.text ?? "Untitled"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Title above card
                Text(selectedTitle)
                    .font(.cardTitle)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 8)

                // Front Card Image
                CardImageContainer(viewModel: viewModel)

                OrnamentalDivider()

                // Titles Picker
                TitlePickerView(card: card)

                // Metadata Lists
                VStack(alignment: .leading, spacing: 16) {
                    MetadataListView(
                        title: "Authors", items: card.authors.map(\.name))
                    MetadataListView(
                        title: "Dates", items: card.dates.map(\.text))
                    MetadataListView(
                        title: "Subjects", items: card.subjects.map(\.name))
                }

                OrnamentalDivider()

                // Reverse label and back view
                Text("Reverse")
                    .font(.cardSubheadline.smallCaps())
                    .fontWeight(.regular)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)

                // Back Card Image
                CardImageContainer(viewModel: viewModel, isBack: true)
            }
            .padding()
        }
    }
}

// MARK: - Card Image Container

private struct CardImageContainer: View {
    @ObservedObject var viewModel: StereoCardViewModel
    var isBack: Bool = false

    var body: some View {
        GeometryReader { geometry in
            if isBack {
                BackCardView(viewModel: viewModel)
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.width / 2
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                FrontCardView(viewModel: viewModel)
                    .frame(
                        width: geometry.size.width,
                        height: geometry.size.width / 2
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .aspectRatio(2 / 1, contentMode: .fit)
    }
}

// MARK: - Title Picker

private struct TitlePickerView: View {
    @Bindable var card: CardSchemaV1.StereoCard

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: "Title")

            Picker("Select Title", selection: $card.titlePick) {
                ForEach(card.titles) { title in
                    Text(title.text)
                        .font(.cardBody)
                        .tag(title as TitleSchemaV1.Title?)
                }
            }
            .labelsHidden()
        }
    }
}

// MARK: - Metadata List

private struct MetadataListView: View {
    let title: String
    let items: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SectionHeader(title: title)

            if items.isEmpty {
                Text("No \(title.lowercased()) available")
                    .font(.cardBody)
                    .foregroundStyle(.secondary)
                    .italic()
            } else {
                ForEach(items, id: \.self) { item in
                    Text(item)
                        .font(.cardBody)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

// MARK: - Preview Provider

#Preview("Card Content") {
    CardContentView(card: PreviewHelper.shared.previewCard)
        .modelContainer(PreviewHelper.shared.modelContainer)
        .frame(width: 600)
}

#Preview("Card Content - Narrow") {
    CardContentView(card: PreviewHelper.shared.previewCard)
        .modelContainer(PreviewHelper.shared.modelContainer)
        .frame(width: 300)
}
