//
//  CardPreviewContainer.swift
//  Retroview
//
//  Created by Adam Schuster on 12/28/24.
//

import SwiftUI
import SwiftData

struct CardPreviewContainer<Content: View>: View {
    let content: (CardSchemaV1.StereoCard) -> Content
    
    init(@ViewBuilder content: @escaping (CardSchemaV1.StereoCard) -> Content) {
        self.content = content
    }
    
    var body: some View {
        PreviewStoreLoader { card in
            content(card)
                .environment(\.imageLoader, CardImageLoader())
        }
    }
}

private struct PreviewStoreLoader<Content: View>: View {
    let content: (CardSchemaV1.StereoCard) -> Content
    
    init(@ViewBuilder content: @escaping (CardSchemaV1.StereoCard) -> Content) {
        self.content = content
    }
    
    var body: some View {
        if let card = PreviewDataManager.shared.singleCard({ card in
            card.imageFrontId != nil && card.leftCrop != nil
        }) {
            content(card)
                .withPreviewStore()
        } else {
            ContentUnavailableView(
                "No Preview Card",
                systemImage: "exclamationmark.triangle",
                description: Text("Could not find a suitable card for preview")
            )
        }
    }
}

extension PreviewDataManager {
    func fetchCards(count: Int = 5, where predicate: ((CardSchemaV1.StereoCard) -> Bool)? = nil) -> [CardSchemaV1.StereoCard] {
        do {
            let context = try container().mainContext
            var descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
            
            // Configure the descriptor
            descriptor.fetchLimit = count
            descriptor.sortBy = [SortDescriptor(\CardSchemaV1.StereoCard.uuid)]
            
            // Fetch cards
            let cards = try context.fetch(descriptor)
            
            // Apply additional filtering if needed
            if let predicate {
                return cards.filter(predicate)
            }
            return cards
        } catch {
            print("Preview data fetch failed: \(error)")
            return []
        }
    }
}

// Preview container for multiple cards
struct CardsPreviewContainer<Content: View>: View {
    let content: ([CardSchemaV1.StereoCard]) -> Content
    let count: Int
    let predicate: ((CardSchemaV1.StereoCard) -> Bool)?
    
    init(
        count: Int = 5,
        where predicate: ((CardSchemaV1.StereoCard) -> Bool)? = nil,
        @ViewBuilder content: @escaping ([CardSchemaV1.StereoCard]) -> Content
    ) {
        self.content = content
        self.count = count
        self.predicate = predicate
    }
    
    var body: some View {
        let cards = PreviewDataManager.shared.fetchCards(count: count, where: predicate)
        if cards.isEmpty {
            ContentUnavailableView(
                "No Preview Cards",
                systemImage: "exclamationmark.triangle",
                description: Text("Could not find suitable cards for preview")
            )
        } else {
            content(cards)
                .withPreviewStore()
                .environment(\.imageLoader, CardImageLoader())
        }
    }
}

#Preview("Card Preview Container") {
    CardPreviewContainer { card in
        VStack {
            Text("Card Title: \(card.titlePick?.text ?? "Untitled")")
            Text("Image ID: \(card.imageFrontId ?? "None")")
            if let leftCrop = card.leftCrop {
                Text("Left Crop: \(leftCrop.description)")
            }
            if let rightCrop = card.rightCrop {
                Text("Right Crop: \(rightCrop.description)")
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding()
    }
}
