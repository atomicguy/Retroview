//
//  MODSJSONImporter.swift
//  Retroview
//
//  Created by Adam Schuster on 12/8/24.
//

import SwiftData
import SwiftUI
import Observation

@Observable
final class MODSJSONImporter {
    var isImporting = false
    var importProgress = 0.0
    var totalCards = 0
    var processedCards = 0
    
    func importJSON(_ jsonData: Data, context: ModelContext) throws {
        isImporting = true
        importProgress = 0.0
        
        Task {
            do {
                let decoder = JSONDecoder()
                let cards = try decoder.decode([StereoCardJSON].self, from: jsonData)
                totalCards = cards.count
                processedCards = 0
                
                print("Starting import of \(totalCards) cards...")
                
                for (index, cardJSON) in cards.enumerated() {
                    await MainActor.run {
                        importProgress = Double(index) / Double(totalCards)
                        processedCards = index
                    }
                    
                    // Updated predicate to use string comparison
                    let descriptor = FetchDescriptor<StereoCard>(
                        predicate: #Predicate<StereoCard> { card in
                            card.uuid.uuidString == cardJSON.uuid
                        }
                    )
                    
                    if let _ = try? context.fetch(descriptor).first {
                        print("Card \(cardJSON.uuid) already exists, skipping...")
                        continue
                    }
                    
                    // Create card with the UUID from JSON
                    guard let uuid = UUID(uuidString: cardJSON.uuid) else {
                        print("Invalid UUID: \(cardJSON.uuid)")
                        continue
                    }
                    
                    let card = StereoCard(
                        uuid: uuid,
                        imageFrontId: cardJSON.imageIds.front,
                        imageBackId: cardJSON.imageIds.back,
                        titles: cardJSON.titles
                    )
                    
                    // Rest of the import code remains the same...
                    let leftCrop = StereoCrop(
                        x0: cardJSON.left.x0,
                        y0: cardJSON.left.y0,
                        x1: cardJSON.left.x1,
                        y1: cardJSON.left.y1,
                        score: cardJSON.left.score,
                        side: .left
                    )
                    
                    let rightCrop = StereoCrop(
                        x0: cardJSON.right.x0,
                        y0: cardJSON.right.y0,
                        x1: cardJSON.right.x1,
                        y1: cardJSON.right.y1,
                        score: cardJSON.right.score,
                        side: .right
                    )
                    
                    card.crops = [leftCrop, rightCrop]
                    
                    for authorName in cardJSON.authors {
                        let descriptor = FetchDescriptor<Author>(
                            predicate: #Predicate<Author> { $0.name == authorName }
                        )
                        
                        let author: Author
                        if let existingAuthor = try? context.fetch(descriptor).first {
                            author = existingAuthor
                        } else {
                            author = Author(name: authorName)
                            context.insert(author)
                        }
                        
                        author.cards.append(card)
                        card.authors.append(author)
                    }
                    
                    for subjectName in cardJSON.subjects {
                        let descriptor = FetchDescriptor<Subject>(
                            predicate: #Predicate<Subject> { $0.name == subjectName }
                        )
                        
                        let subject: Subject
                        if let existingSubject = try? context.fetch(descriptor).first {
                            subject = existingSubject
                        } else {
                            subject = Subject(name: subjectName)
                            context.insert(subject)
                        }
                        
                        subject.cards.append(card)
                        card.subjects.append(subject)
                    }
                    
                    context.insert(card)
                    
                    if index % 10 == 0 {
                        try? context.save()
                        print("Saved batch at index \(index)")
                    }
                }
                
                try context.save()
                print("Import completed successfully")
                
                await MainActor.run {
                    importProgress = 1.0
                    isImporting = false
                }
            } catch {
                print("Import error: \(error)")
                await MainActor.run {
                    isImporting = false
                    importProgress = 0.0
                }
                throw error
            }
        }
    }
}
