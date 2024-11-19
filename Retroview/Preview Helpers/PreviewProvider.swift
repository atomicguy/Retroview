//
// PreviewHelper.swift
//  Retroview
//
//  Created by Adam Schuster on 11/17/24.
//

import SwiftData
import SwiftUI
#if os(macOS)
import AppKit
#else
import UIKit
#endif

// MARK: - Preview Helpers

extension View {
    func withPreviewContainer() -> some View {
        self
            .modelContainer(PreviewHelper.shared.modelContainer)
            .environmentObject(PreviewHelper.shared.windowStateManager)
    }
}

struct PreviewContainer<Content: View>: View {
    let content: () -> Content
    
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        content()
            .withPreviewContainer()
    }
}

// MARK: - Preview Helper

@MainActor
final class PreviewHelper {
    static let shared = PreviewHelper()
    
    let modelContainer: ModelContainer
    let windowStateManager = WindowStateManager.shared
    
    private init() {
        let schema = Schema([
            CardSchemaV1.StereoCard.self,
            TitleSchemaV1.Title.self,
            AuthorSchemaV1.Author.self,
            SubjectSchemaV1.Subject.self,
            DateSchemaV1.Date.self,
            CropSchemaV1.Crop.self
        ])
        
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [config])
            insertSampleData()
        } catch {
            fatalError("Could not create preview ModelContainer: \(error)")
        }
    }
    
    private func insertSampleData() {
        let context = modelContainer.mainContext
        
        // Insert sample data
        for card in CardSchemaV1.StereoCard.sampleData {
            context.insert(card)
        }
        
        for title in TitleSchemaV1.Title.sampleData {
            context.insert(title)
        }
        
        for author in AuthorSchemaV1.Author.sampleData {
            context.insert(author)
        }
        
        for subject in SubjectSchemaV1.Subject.sampleData {
            context.insert(subject)
        }
        
        for date in DateSchemaV1.Date.sampleData {
            context.insert(date)
        }
        
        // Setup relationships
        setupSampleRelationships()
        
        do {
            try context.save()
        } catch {
            print("Sample data context failed to save: \(error)")
        }
    }
    
    private func setupSampleRelationships() {
        // Add titles
        CardSchemaV1.StereoCard.sampleData[0].titles = [
            TitleSchemaV1.Title.sampleData[0],
            TitleSchemaV1.Title.sampleData[1]
        ]
        CardSchemaV1.StereoCard.sampleData[0].titlePick = TitleSchemaV1.Title.sampleData[0]
        
        CardSchemaV1.StereoCard.sampleData[1].titles = [
            TitleSchemaV1.Title.sampleData[2],
            TitleSchemaV1.Title.sampleData[3]
        ]
        CardSchemaV1.StereoCard.sampleData[1].titlePick = TitleSchemaV1.Title.sampleData[3]
        
        // Add authors
        CardSchemaV1.StereoCard.sampleData[0].authors = [AuthorSchemaV1.Author.sampleData[0]]
        CardSchemaV1.StereoCard.sampleData[1].authors = [AuthorSchemaV1.Author.sampleData[0]]
        
        // Add subjects
        CardSchemaV1.StereoCard.sampleData[0].subjects = [
            SubjectSchemaV1.Subject.sampleData[0],
            SubjectSchemaV1.Subject.sampleData[1],
            SubjectSchemaV1.Subject.sampleData[2],
            SubjectSchemaV1.Subject.sampleData[3]
        ]
        
        CardSchemaV1.StereoCard.sampleData[1].subjects = [
            SubjectSchemaV1.Subject.sampleData[0],
            SubjectSchemaV1.Subject.sampleData[1],
            SubjectSchemaV1.Subject.sampleData[2],
            SubjectSchemaV1.Subject.sampleData[3]
        ]
        
        // Add dates
        CardSchemaV1.StereoCard.sampleData[0].dates = [DateSchemaV1.Date.sampleData[0]]
        CardSchemaV1.StereoCard.sampleData[1].dates = [DateSchemaV1.Date.sampleData[0]]
        
        // Add crops
        CardSchemaV1.StereoCard.sampleData[0].leftCrop = CropSchemaV1.Crop.sampleData[0]
        CardSchemaV1.StereoCard.sampleData[0].rightCrop = CropSchemaV1.Crop.sampleData[1]
        CardSchemaV1.StereoCard.sampleData[1].leftCrop = CropSchemaV1.Crop.sampleData[2]
        CardSchemaV1.StereoCard.sampleData[1].rightCrop = CropSchemaV1.Crop.sampleData[3]
    }
    
    var previewCard: CardSchemaV1.StereoCard {
        get {
            CardSchemaV1.StereoCard.sampleData[0]
        }
    }
    
    var previewCards: [CardSchemaV1.StereoCard] {
        get {
            CardSchemaV1.StereoCard.sampleData
        }
    }
}

// MARK: - Convenience Preview Containers

struct AsyncPreviewContainer<Content: View>: View {
    let content: () async -> Content
    @State private var loadedView: Content?
    
    init(@ViewBuilder content: @escaping () async -> Content) {
        self.content = content
    }
    
    var body: some View {
        Group {
            if let loadedView {
                loadedView.withPreviewContainer()
            } else {
                ProgressView("Loading preview...")
                    .task {
                        loadedView = await content()
                    }
            }
        }
    }
}

struct CardPreviewContainer<Content: View>: View {
    let content: (CardSchemaV1.StereoCard) -> Content
    
    init(@ViewBuilder content: @escaping (CardSchemaV1.StereoCard) -> Content) {
        self.content = content
    }
    
    var body: some View {
        content(PreviewHelper.shared.previewCard)
            .withPreviewContainer()
    }
}

struct CardsPreviewContainer<Content: View>: View {
    let content: ([CardSchemaV1.StereoCard]) -> Content
    
    init(@ViewBuilder content: @escaping ([CardSchemaV1.StereoCard]) -> Content) {
        self.content = content
    }
    
    var body: some View {
        content(PreviewHelper.shared.previewCards)
            .withPreviewContainer()
    }
}


// MARK: - Preview Usage Examples

//#Preview("Single Card") {
//    CardPreviewContainer { card in
//        UnifiedCardView(card: card)
//    }
//}

#Preview("Card Grid") {
    CardsPreviewContainer { cards in
        ScrollView {
            LazyVGrid(columns: [.init(.adaptive(minimum: 300))]) {
                ForEach(cards) { card in
                    UnifiedCardView(card: card)
                }
            }
            .padding()
        }
    }
}
