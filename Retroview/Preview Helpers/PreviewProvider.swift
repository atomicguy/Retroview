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

@MainActor
final class PreviewHelper {
    static let shared = PreviewHelper()
    
    let modelContainer: ModelContainer
    let windowStateManager: WindowStateManager
    
    // Sample data arrays
    private let sampleTitles = [
        "Niagara Falls from Prospect Point",
        "Golden Gate from Telegraph Hill",
        "Broadway at Night, New York",
        "Grand Canyon from Hopi Point"
    ]
    
    private let sampleAuthors = [
        "Kilburn, B. W.",
        "Underwood & Underwood",
        "H. C. White Co."
    ]
    
    private let sampleSubjects = [
        "Natural Wonders",
        "Urban Landscapes",
        "American Cities",
        "National Parks"
    ]
    
    private let sampleDates = ["1885", "1899", "1901", "1905"]
    
    // Create preview image data
    private func generatePreviewImage() async -> Data? {
        await withCheckedContinuation { continuation in
            let size = CGSize(width: 800, height: 400)
            let renderer = ImageRenderer(content:
                ZStack {
                    Color.gray.opacity(0.2)
                    VStack {
                        Image(systemName: "photo")
                            .font(.system(size: 60))
                        Text("Preview Image")
                            .font(.title)
                    }
                }
                .frame(width: size.width, height: size.height)
            )
            
            renderer.scale = 2.0
            
            #if os(macOS)
            if let nsImage = renderer.nsImage {
                continuation.resume(returning: nsImage.tiffRepresentation)
            } else {
                continuation.resume(returning: nil)
            }
            #else
            if let uiImage = renderer.uiImage {
                continuation.resume(returning: uiImage.pngData())
            } else {
                continuation.resume(returning: nil)
            }
            #endif
        }
    }
    
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
        } catch {
            fatalError("Could not create preview ModelContainer: \(error)")
        }
        
        windowStateManager = WindowStateManager.shared
    }
    
    // Create a single preview card with optional index for varying data
    func createPreviewCard(index: Int = 0) async -> CardSchemaV1.StereoCard {
        let context = modelContainer.mainContext
        let imageData = await generatePreviewImage()
        
        let card = CardSchemaV1.StereoCard(
            uuid: "preview-card-\(index)",
            imageFront: imageData,
            imageFrontId: "G90F186_\(index)F",
            imageBack: imageData,
            imageBackId: "G90F186_\(index)B"
        )
        
        // Create and add relationships
        let title = TitleSchemaV1.Title(text: sampleTitles[index % sampleTitles.count])
        let author = AuthorSchemaV1.Author(name: sampleAuthors[index % sampleAuthors.count])
        let subject = SubjectSchemaV1.Subject(name: sampleSubjects[index % sampleSubjects.count])
        let date = DateSchemaV1.Date(text: sampleDates[index % sampleDates.count])
        
        context.insert(card)
        context.insert(title)
        context.insert(author)
        context.insert(subject)
        context.insert(date)
        
        card.titles = [title]
        card.titlePick = title
        card.authors = [author]
        card.subjects = [subject]
        card.dates = [date]
        
        // Add sample crops
        let leftCrop = CropSchemaV1.Crop(
            x0: 0.05, y0: 0.07,
            x1: 0.86, y1: 0.48,
            score: 0.99,
            side: CropSchemaV1.Side.left.rawValue
        )
        
        let rightCrop = CropSchemaV1.Crop(
            x0: 0.05, y0: 0.48,
            x1: 0.86, y1: 0.90,
            score: 0.99,
            side: CropSchemaV1.Side.right.rawValue
        )
        
        card.leftCrop = leftCrop
        card.rightCrop = rightCrop
        
        try? context.save()
        return card
    }
    
    // Create multiple preview cards
    func createPreviewCards(count: Int = 4) async -> [CardSchemaV1.StereoCard] {
        var cards: [CardSchemaV1.StereoCard] = []
        for index in 0 ..< count {
            let card = await createPreviewCard(index: index)
            cards.append(card)
        }
        return cards
    }
    
    // Convenience properties
    var previewCard: CardSchemaV1.StereoCard {
        get async {
            await createPreviewCard()
        }
    }
    
    var previewCards: [CardSchemaV1.StereoCard] {
        get async {
            await createPreviewCards()
        }
    }
}

struct AsyncPreviewContainer<Content: View>: View {
    let content: () async -> Content
    @State private var loadedView: Content?
    
    init(@ViewBuilder content: @escaping () async -> Content) {
        self.content = content
    }
    
    var body: some View {
        Group {
            if let loadedView = loadedView {
                loadedView
                    .modelContainer(PreviewHelper.shared.modelContainer)
                    .environmentObject(PreviewHelper.shared.windowStateManager)
            } else {
                ProgressView("Loading preview...")
                    .task {
                        loadedView = await content()
                    }
            }
        }
    }
}

// Helper for previewing card-based views
struct CardPreviewContainer<Content: View>: View {
    let content: (CardSchemaV1.StereoCard) -> Content
    @State private var card: CardSchemaV1.StereoCard?
    
    init(@ViewBuilder content: @escaping (CardSchemaV1.StereoCard) -> Content) {
        self.content = content
    }
    
    var body: some View {
        if let card = card {
            content(card)
        } else {
            ProgressView()
                .task {
                    card = await PreviewHelper.shared.previewCard
                }
        }
    }
}

struct CardsPreviewContainer<Content: View>: View {
    let content: ([CardSchemaV1.StereoCard]) -> Content
    @StateObject private var windowStateManager = WindowStateManager.shared
    
    init(@ViewBuilder content: @escaping ([CardSchemaV1.StereoCard]) -> Content) {
        self.content = content
    }
    
    var body: some View {
        content(SampleData.shared.cards)
            .modelContainer(SampleData.shared.modelContainer)
            .environmentObject(windowStateManager)
    }
}
