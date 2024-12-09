//
//  StereoCard.swift
//  Retroview
//
//  Created by Adam Schuster on 12/8/24.
//

import Foundation
import SwiftData

@Model
final class StereoCard {
    // MARK: - Properties
    @Attribute(.unique) var uuid: UUID
    @Attribute(.transformable(by: NSSecureUnarchiveFromDataTransformer.self)) var titles: [String]
    var primaryTitle: String
    
    // MARK: - Image Data
    var imageFrontId: String?
    var imageBackId: String?
    @Attribute(.externalStorage) var imageFront: Data?
    @Attribute(.externalStorage) var imageBack: Data?
    
    // MARK: - Display Properties
    var cardColor: String
    var colorOpacity: Double
    
    // MARK: - Relationships
    @Relationship(deleteRule: .cascade) var crops: [StereoCrop]
    @Relationship var collections: [Collection]
    @Relationship var authors: [Author]
    @Relationship var subjects: [Subject]
    @Relationship var dates: [DateReference]
    @Relationship var modsDates: [MODSDate]
    
    // MARK: - Initialization
    init(uuid: UUID = UUID(),
         imageFrontId: String? = nil,
         imageBackId: String? = nil,
         cardColor: String = "#F5E6D3",
         colorOpacity: Double = 0.15,
         titles: [String] = []) {
        self.uuid = uuid
        self.imageFrontId = imageFrontId
        self.imageBackId = imageBackId
        self.cardColor = cardColor
        self.colorOpacity = colorOpacity
        self.titles = titles
        self.primaryTitle = titles.first ?? "Untitled"
        
        // Initialize relationship arrays
        self.crops = []
        self.collections = []
        self.authors = []
        self.subjects = []
        self.dates = []
        self.modsDates = []
    }
}

// Add convenience methods to StereoCard:
extension StereoCard {
    func addToCollection(_ collection: Collection) {
        collections.append(collection)
        collection.addCard(self)
    }

    func removeFromCollection(_ collection: Collection) {
        collections.removeAll { $0.id == collection.id }
        collection.removeCard(self)
    }
}
