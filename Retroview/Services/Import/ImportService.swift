//
//  ImportService.swift
//  Retroview
//
//  Created by Adam Schuster on 12/9/24.
//

import Foundation
import SwiftData

@Observable @MainActor
final class ImportService {
    static let shared = ImportService(modelContext: .shared)
    
    static func getShared() async -> ImportService {
        await MainActor.run { shared }
    }
    
    private let modelContext: ModelContext
    private let imageService: ImageService
    
    init(
        modelContext: ModelContext,
        imageService: ImageService? = nil
    ) {
        self.modelContext = modelContext
        // Initialize imageService asynchronously after construction if needed
        self.imageService = imageService ?? .shared()
    }
    
    func importCards(from url: URL) -> AsyncStream<Progress> {
        AsyncStream { continuation in
            Task {
                do {
                    let fileURLs = try FileManager.default.contentsOfDirectory(
                        at: url,
                        includingPropertiesForKeys: [.isRegularFileKey],
                        options: .skipsHiddenFiles
                    ).filter { $0.pathExtension.lowercased() == "json" }
                    
                    let progress = Progress(totalUnitCount: Int64(fileURLs.count))
                    continuation.yield(progress)
                    
                    for fileURL in fileURLs {
                        try await importCard(from: fileURL)
                        progress.completedUnitCount += 1
                        continuation.yield(progress)
                    }
                    
                    continuation.finish()
                } catch {
                    continuation.finish()
                }
            }
        }
    }
    
    private func importCard(from url: URL) async throws {
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let cardDTO = try decoder.decode(StereoCardDTO.self, from: data)
        
        let card = CardSchemaV1.StereoCard(
            uuid: cardDTO.uuid,
            imageFrontId: cardDTO.imageIds.front,
            imageBackId: cardDTO.imageIds.back
        )
        
        // Create relationships
        await createRelationships(for: card, from: cardDTO)
        
        // Download images
        await downloadImages(for: card)
        
        modelContext.insert(card)
        try modelContext.save()
    }
    
    private func createRelationships(for card: CardSchemaV1.StereoCard, from dto: StereoCardDTO) async {
        // Create titles
        for titleText in dto.titles {
            let descriptor = FetchDescriptor<TitleSchemaV1.Title>(
                predicate: #Predicate<TitleSchemaV1.Title> { $0.text == titleText }
            )
            
            if let existingTitle = try? modelContext.fetch(descriptor).first {
                card.titles.append(existingTitle)
            } else {
                let newTitle = TitleSchemaV1.Title(text: titleText)
                modelContext.insert(newTitle)
                card.titles.append(newTitle)
            }
        }
        card.titlePick = card.titles.first
        
        // Create authors
        for authorName in dto.authors {
            let descriptor = FetchDescriptor<AuthorSchemaV1.Author>(
                predicate: #Predicate<AuthorSchemaV1.Author> { $0.name == authorName }
            )
            
            if let existingAuthor = try? modelContext.fetch(descriptor).first {
                card.authors.append(existingAuthor)
            } else {
                let newAuthor = AuthorSchemaV1.Author(name: authorName)
                modelContext.insert(newAuthor)
                card.authors.append(newAuthor)
            }
        }
        
        // Create subjects
        for subjectName in dto.subjects {
            let descriptor = FetchDescriptor<SubjectSchemaV1.Subject>(
                predicate: #Predicate<SubjectSchemaV1.Subject> { $0.name == subjectName }
            )
            
            if let existingSubject = try? modelContext.fetch(descriptor).first {
                card.subjects.append(existingSubject)
            } else {
                let newSubject = SubjectSchemaV1.Subject(name: subjectName)
                modelContext.insert(newSubject)
                card.subjects.append(newSubject)
            }
        }
        
        // Create dates
        for dateText in dto.dates {
            let descriptor = FetchDescriptor<DateSchemaV1.Date>(
                predicate: #Predicate<DateSchemaV1.Date> { $0.text == dateText }
            )
            
            if let existingDate = try? modelContext.fetch(descriptor).first {
                card.dates.append(existingDate)
            } else {
                let newDate = DateSchemaV1.Date(text: dateText)
                modelContext.insert(newDate)
                card.dates.append(newDate)
            }
        }
        
        // Create crops
        let leftCrop = CropSchemaV1.Crop(
            x0: dto.left.x0,
            y0: dto.left.y0,
            x1: dto.left.x1,
            y1: dto.left.y1,
            score: dto.left.score,
            side: dto.left.side
        )
        card.leftCrop = leftCrop
        
        let rightCrop = CropSchemaV1.Crop(
            x0: dto.right.x0,
            y0: dto.right.y0,
            x1: dto.right.x1,
            y1: dto.right.y1,
            score: dto.right.score,
            side: dto.right.side
        )
        card.rightCrop = rightCrop
    }
    
    private func downloadImages(for card: CardSchemaV1.StereoCard) async {
        if let frontId = card.imageFrontId {
            if let frontImage = try? await imageService.loadImage(id: frontId, side: .front),
               let imageData = ImageConversion.convert(cgImage: frontImage) {
                card.imageFront = imageData
            }
        }
        
        if let backId = card.imageBackId {
            if let backImage = try? await imageService.loadImage(id: backId, side: .back),
               let imageData = ImageConversion.convert(cgImage: backImage) {
                card.imageBack = imageData
            }
        }
    }
}
