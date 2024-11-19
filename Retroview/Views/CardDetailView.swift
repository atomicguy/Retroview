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
        _viewModel = StateObject(wrappedValue: StereoCardViewModel(stereoCard: card))
    }

    @Environment(\.modelContext) private var context

    var displayTitle: TitleSchemaV1.Title {
        card.titlePick ?? card.titles.first ?? TitleSchemaV1.Title(text: "Unknown")
    }

    var sortedAuthors: [AuthorSchemaV1.Author] {
        card.authors.sorted { first, second in first.name < second.name }
    }

    var sortedSubjects: [SubjectSchemaV1.Subject] {
        card.subjects.sorted { first, second in first.name < second.name }
    }

    var sortedDates: [DateSchemaV1.Date] {
        card.dates.sorted { first, second in first.text < second.text }
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

                StereoPreviewButton(
                    viewModel: viewModel,
                    showingStereoView: $showingStereoView,
                    card: card
                )

                MetadataView(
                    uuid: card.uuid,
                    authors: sortedAuthors,
                    subjects: sortedSubjects,
                    dates: sortedDates
                )
            }
            .padding()
        }
    }
}

// Break out the stereo preview button for better organization
private struct StereoPreviewButton: View {
    @ObservedObject var viewModel: StereoCardViewModel
    @Binding var showingStereoView: Bool
    let card: CardSchemaV1.StereoCard
    
    var body: some View {
        Button(action: { showingStereoView = true }) {
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
        .buttonStyle(PlainButtonStyle())
        .fullScreenCover(isPresented: $showingStereoView) {
            FullScreenStereoView(card: card)
        }
    }
}

// Break out the metadata view for better organization
private struct MetadataView: View {
    let uuid: UUID
    let authors: [AuthorSchemaV1.Author]
    let subjects: [SubjectSchemaV1.Subject]
    let dates: [DateSchemaV1.Date]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(uuid.uuidString)
                .font(.system(.caption, design: .serif))
            
            if !authors.isEmpty {
                MetadataSection(title: "Authors:", items: authors.map(\.name))
            }
            
            if !subjects.isEmpty {
                MetadataSection(title: "Subjects:", items: subjects.map(\.name))
            }
            
            if !dates.isEmpty {
                MetadataSection(title: "Dates:", items: dates.map(\.text))
            }
        }
        .font(.system(.body, design: .serif))
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

// Update the preview
#Preview {
    NavigationStack {
        CardDetailView(card: SampleData.shared.card)
            .modelContainer(SampleData.shared.modelContainer)
    }
}
