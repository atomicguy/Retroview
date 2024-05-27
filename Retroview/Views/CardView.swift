//
//  CardView.swift
//  Retroview
//
//  Created by Adam Schuster on 5/12/24.
//

import SwiftUI
import SwiftData

struct CardView: View {
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
        VStack(alignment: .leading) {

            AsyncImage(url: card.imageUrl(forSide: "front")) { phase in
                if let image = phase.image{
                    image.resizable()
                } else if phase.error != nil {
                    Color.red
                } else {
                    Color.blue
                }
            }
            .frame(width: 400, height: 205)
//            URLImageView(url: card.imageUrl(forSide: "front"), side: "front", card: card)
//                            .frame(width: 400, height: 205)
            Text(displayTitle.text)
                .font(.system(.title, design: .serif))
            Text(card.uuid.uuidString)
                .font(.caption)
            if !card.authors.isEmpty {
                HStack(alignment: .top){
                    Text("Authors:")
                    VStack(alignment: .leading){
                        ForEach(sortedAuthors) { author in
                            Text(author.name)
                        }
                    }
                }
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
            }
        }
        .padding()
    }
}

#Preview {
    CardView(card: SampleData.shared.card)
        .modelContainer(SampleData.shared.modelContainer)
}
