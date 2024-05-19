//
//  SampleData.swift
//  Retroview
//
//  Created by Adam Schuster on 5/11/24.
//

import Foundation
import SwiftData

@MainActor
class SampleData {
    static let shared = SampleData()
    
    let modelContainer: ModelContainer
    
    var context: ModelContext {
        modelContainer.mainContext
    }
    
    private init() {
        let schema = Schema([CardSchemaV1.StereoCard.self, TitleSchemaV1.Title.self, AuthorSchemaV1.Author.self])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        
        do {
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            print("ModelContainer created successfully")
            insertSampleData()
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
        
        print(URL.applicationSupportDirectory.path(percentEncoded: false))
        
    }
    
    func insertSampleData() {
        for card in CardSchemaV1.StereoCard.sampleData {
            context.insert(card)
            print("card inserted:", card.uuid)
        }
        
        for title in TitleSchemaV1.Title.sampleData {
            context.insert(title)
            print("title inserted:", title.text)
        }
        
        
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
        
        
        do {
            try context.save()
        } catch {
            print("Sample data context failed to save")
        }
    }
    
    var card: CardSchemaV1.StereoCard {
        CardSchemaV1.StereoCard.sampleData[0]
    }
    
    var cards: [CardSchemaV1.StereoCard] {
        CardSchemaV1.StereoCard.sampleData
    }
}
