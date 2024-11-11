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
    @State private var showingStereoView = false
    @StateObject private var viewModel: StereoCardViewModel

    @Environment(\.modelContext) private var context

    init(card: CardSchemaV1.StereoCard) {
        self.card = card
        _viewModel = StateObject(
            wrappedValue: StereoCardViewModel(stereoCard: card))
    }

    var displayTitle: TitleSchemaV1.Title {
        card.titlePick ?? card.titles.first
            ?? TitleSchemaV1.Title(text: "Unknown")
    }

    var sortedAuthors: [AuthorSchemaV1.Author] {
        card.authors.sorted { first, second in
            first.name < second.name
        }
    }

    var sortedSubjects: [SubjectSchemaV1.Subject] {
        card.subjects.sorted { first, second in
            first.name < second.name
        }
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
                    FrontCardView(viewModel: viewModel)
                        .frame(width: 400, height: 200)
                    BackCardView(viewModel: viewModel)
                        .frame(width: 400, height: 200)
                }
                .frame(maxWidth: .infinity, alignment: .center)

                // Stereo preview button
                Button(action: { showingStereoView = true }) {
                    ZStack {
                        if let frontImage = viewModel.frontCGImage {
                            Image(decorative: frontImage, scale: 1.0)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: .infinity)
                                .frame(height: 200)
                                .overlay(
                                    Rectangle()
                                        .fill(Color.black.opacity(0.3))
                                )
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

                Text(card.uuid.uuidString)
                    .font(.system(.caption, design: .serif))
                if !card.authors.isEmpty {
                    HStack(alignment: .top) {
                        Text("Authors:")
                        VStack(alignment: .leading) {
                            ForEach(sortedAuthors) { author in
                                Text(author.name)
                            }
                        }
                    }
                    .font(.system(.body, design: .serif))
                }
                if !card.subjects.isEmpty {
                    HStack(alignment: .top) {
                        Text("Subjects:")
                        VStack(alignment: .leading) {
                            ForEach(sortedSubjects) {
                                subject in
                                Text(subject.name)
                            }
                        }
                    }
                    .font(.system(.body, design: .serif))
                }
                if !card.dates.isEmpty {
                    HStack(alignment: .top) {
                        Text("Dates:")
                        VStack(alignment: .leading) {
                            ForEach(sortedDates) {
                                date in
                                Text(date.text)
                            }
                        }
                    }
                    .font(.system(.body, design: .serif))
                }
            }
            .padding()
        }
        .onAppear {
            Task {
                try? await viewModel.loadImage(forSide: "front")
            }
        }
    }
}

#Preview {
    CardDetailView(card: SampleData.shared.card)
        .modelContainer(SampleData.shared.modelContainer)
}
