//
//  CardTitlesSection.swift
//  Retroview
//
//  Created by Adam Schuster on 12/22/24.
//

import SwiftUI

struct CardTitlesSection: View {
    let card: CardSchemaV1.StereoCard
    let updateTitlePick: (TitleSchemaV1.Title) -> Void
    
    // Compute sorted titles with picked title first
    private var sortedTitles: [TitleSchemaV1.Title] {
        var titles = card.titles
        if let pickedIndex = titles.firstIndex(where: { $0 == card.titlePick }) {
            let pickedTitle = titles.remove(at: pickedIndex)
            titles.insert(pickedTitle, at: 0)
        }
        return titles
    }
    
    var body: some View {
        MetadataSection(title: "Titles") {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(sortedTitles, id: \.text) { title in
                    titleButton(for: title)
                }
            }
        }
    }
    
    private func titleButton(for title: TitleSchemaV1.Title) -> some View {
        Button {
            updateTitlePick(title)
        } label: {
            HStack {
                // Checkmark or empty circle before the title
                if title == card.titlePick {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.primary)
                } else {
                    Image(systemName: "circle")
                        .foregroundStyle(.secondary)
                }
                
                Text(title.text)
                    .font(.system(.body, design: .serif))
                    .foregroundStyle(.primary)
                
                Spacer()
            }
            .padding(8)
            .background(title == card.titlePick
                ? Color.primary.opacity(0.1)
                : Color.secondary.opacity(0.05))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

#if DEBUG
import SwiftData

#Preview("Card Title Section") {
    let previewContainer = try! PreviewDataManager.shared.container()
    let card = try! previewContainer.mainContext.fetch(FetchDescriptor<CardSchemaV1.StereoCard>()).first!
    
    return CardTitlesSection(card: card) { _ in }
        .withPreviewStore()
        .padding()
}
#endif
