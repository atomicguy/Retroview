//
//  StereoCardListView.swift
//  Retroview
//
//  Created by Adam Schuster on 12/10/24.
//

import SwiftUI
import SwiftData

struct StereoCardListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \StereoCard.primaryTitle) private var cards: [StereoCard]
    
    var body: some View {
        List(cards) { card in
            StereoCardListItemView(card: card)
        }
    }
}

struct StereoCardListItemView: View {
    let card: StereoCard
    
    private var formattedDate: String {
        guard let firstDate = card.dates.first?.dateString else {
            return "Date unknown"
        }
        return firstDate
    }
    
    private var authorName: String {
        guard let firstAuthor = card.authors.first?.name else {
            return "Unknown author"
        }
        return firstAuthor
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(card.primaryTitle)
                .font(.headline)
            
            HStack {
                Text(authorName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Text(formattedDate)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Text(card.uuid.uuidString)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    StereoCardListView()
        .modelContainer(previewContainer)
}

@MainActor
private let previewContainer: ModelContainer = {
    let schema = Schema([
        StereoCard.self,
        Author.self,
        DateReference.self
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    
    do {
        let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        let sampleCard = StereoCard(
            titles: ["Sample Stereocard"],
            cardColor: "#F5E6D3"
        )
        
        let author = Author(name: "John Doe")
        sampleCard.authors = [author]
        
        let date = DateReference(
            date: Date(),
            dateString: "1875"
        )
        sampleCard.dates = [date]
        
        container.mainContext.insert(sampleCard)
        return container
    } catch {
        fatalError("Failed to create preview container: \(error.localizedDescription)")
    }
}()
