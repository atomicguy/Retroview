//
//  CardCollectionScreen.swift
//  Retroview
//
//  Created by Adam Schuster on 4/28/24.
//

import SwiftUI
import SwiftData

struct CardCollectionScreen: View {
    
    @Environment(\.modelContext) private var context
    
    @Query private var cards: [CardSchemaV1.StereoCard]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Stereoview Cards")
                .font(.largeTitle)
            NavigationStack {
                CardListView(cards: cards)
            }
        }
        .padding()
    }
}

#Preview {
    NavigationStack{
        CardCollectionScreen()
            .modelContainer(SampleData.shared.modelContainer)
    }
}
