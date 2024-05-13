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
        card.titlePick ?? card.titles[0]
    }
    
    var sortedAuthors: [AuthorSchemaV1.Author] {
        card.authors.sorted { first, second in
            first.name < second.name
        }
    }
    
    var body: some View {
        VStack {
            Text(displayTitle.text)
                .font(.system(.headline, design: .serif))
            Text(card.uuid.uuidString)
                .font(.caption)
            if !card.authors.isEmpty {
                Section("Authors:") {
                    ForEach(sortedAuthors) { author in
                        Text(author.name)
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
