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
        
        var body: some View {
            VStack(alignment: .leading) {

                AsyncImage(url: card.imageUrl(forSide: "front")) { phase in
                    if let image = phase.image{
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } else if phase.error != nil {
                        Color.red
                    } else {
                        Color.secondary
                    }
                }
                .frame(width: 760, height: 390)
                Text(displayTitle.text)
                    .font(.system(.title, design: .serif))
                Text(card.uuid.uuidString)
                    .font(.caption)
               
            }
            .padding()
        }
}

#Preview {
    CardDetailView(card: SampleData.shared.card)
        .modelContainer(SampleData.shared.modelContainer)
}
