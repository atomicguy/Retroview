//
//  PreviewContainerHelpers.swift
//  Retroview
//
//  Created by Adam Schuster on 12/7/24.
//

import SwiftUI
import SwiftData

// MARK: - Card Preview Container
struct CardPreviewContainer<Content: View>: View {
    @State private var card: CardSchemaV1.StereoCard?
    let content: (CardSchemaV1.StereoCard) -> Content
    
    init(@ViewBuilder content: @escaping (CardSchemaV1.StereoCard) -> Content) {
        self.content = content
    }
    
    var body: some View {
        Group {
            if let card {
                content(card)
            } else {
                ProgressView()
            }
        }
        .task {
            do {
                try await PreviewDataManager.shared.populatePreviewData()
                let container = try PreviewDataManager.shared.container()
                let descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
                card = try container.mainContext.fetch(descriptor).first
            } catch {
                print("Preview error: \(error)")
            }
        }
        .withPreviewData()
    }
}

// MARK: - Cards Preview Container
struct CardsPreviewContainer<Content: View>: View {
    @State private var cards: [CardSchemaV1.StereoCard] = []
    let content: ([CardSchemaV1.StereoCard]) -> Content
    
    init(@ViewBuilder content: @escaping ([CardSchemaV1.StereoCard]) -> Content) {
        self.content = content
    }
    
    var body: some View {
        Group {
            if !cards.isEmpty {
                content(cards)
            } else {
                ProgressView()
            }
        }
        .task {
            do {
                try await PreviewDataManager.shared.populatePreviewData()
                let container = try PreviewDataManager.shared.container()
                let descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
                cards = try container.mainContext.fetch(descriptor)
            } catch {
                print("Preview error: \(error)")
            }
        }
        .withPreviewData()
    }
}

// MARK: - ModelContext Extension for Previews
extension ModelContext {
    func cardSampleData() -> CardSchemaV1.StereoCard? {
        let descriptor = FetchDescriptor<CardSchemaV1.StereoCard>()
        return try? fetch(descriptor).first
    }
    
    func collectionSampleData() -> CollectionSchemaV1.Collection? {
        let descriptor = FetchDescriptor<CollectionSchemaV1.Collection>()
        return try? fetch(descriptor).first
    }
}
