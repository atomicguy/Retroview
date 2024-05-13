//
//  CardDetailView.swift
//  Retroview
//
//  Created by Adam Schuster on 5/12/24.
//

import SwiftUI
import SwiftData

struct CardDetailView: View {
    @Bindable var card: CardSchemaV1.StereoCard
    @Environment(\.modelContext) private var context
    
    var body: some View {
        HStack {
            Text(card.titlePick?.text ?? card.titles[0].text)
        }
        .background(.background, in: RoundedRectangle(cornerRadius: 12))
        .foregroundStyle(.primary)
    }
}

#Preview {
    NavigationStack {
        CardDetailView(card: SampleData.shared.card1)
    }
    .modelContainer(SampleData.shared.modelContainer)
}
