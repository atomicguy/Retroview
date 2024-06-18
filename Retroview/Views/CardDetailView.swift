//
//  CardDetails.swift
//  Retroview
//
//  Created by Adam Schuster on 5/27/24.
//

import SwiftUI
import SwiftData

struct CardDetailView: View {
    @Bindable var card: CardSchemaV1.StereoCard
    
    @Environment(\.modelContext) private var context
    
    var displayTitle: TitleSchemaV1.Title {
        card.titlePick ?? card.titles.first ?? TitleSchemaV1.Title(text: "Unknown")
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
        card.dates.sorted { first, second in first.text < second.text}
    }
    
    var body: some View {
        ScrollView{
            VStack(alignment: .leading) {
                let viewModel = StereoCardViewModel(stereoCard: card)
                HStack(alignment: .center) {
                    FrontCardView(viewModel: viewModel)
                    .frame(width: 400, height: 200)
                    BackCardView(viewModel: viewModel)
                    .frame(width: 400, height: 200)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                Text(displayTitle.text)
                    .font(.system(.title, design: .serif))
                    .frame(maxWidth: .infinity, alignment: .center)
                Text(card.uuid.uuidString)
                    .font(.system(.caption, design: .serif))
                if !card.authors.isEmpty {
                    HStack(alignment: .top){
                        Text("Authors:")
                        VStack(alignment: .leading){
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
                        VStack(alignment: .leading){
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
                        VStack(alignment: .leading){
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
        }
}

#Preview {
    CardDetailView(card: SampleData.shared.card)
        .modelContainer(SampleData.shared.modelContainer)
}
