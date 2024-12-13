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
    // MARK: - Core Properties
    @Attribute(.unique) var uuid: UUID
    @Attribute(originalName: "titles") private var _titleArray: [String]
    var primaryTitle: String
    
    var titles: [String] {
        get { _titleArray }
        set {
            _titleArray = newValue
            primaryTitle = newValue.first ?? "Untitled"
        }
    }
    
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
    
    // MARK: - MODS Metadata
    var modsIdentifiers: [String: String]
    var rightsStatement: String?
    @Attribute(originalName: "notes") private var _notesArray: [String]
    
    var notes: [String] {
        get { _notesArray }
        set { _notesArray = newValue }
    }
    
    // MARK: - Initialization
    init(uuid: UUID = UUID(),
         titles: [String],
         imageFrontId: String? = nil,
         imageBackId: String? = nil,
         cardColor: String = "#F5E6D3",
         colorOpacity: Double = 0.15,
         modsIdentifiers: [String: String] = [:],
         rightsStatement: String? = nil,
         notes: [String] = []) {
        self.uuid = uuid
        self._titleArray = titles
        self.primaryTitle = titles.first ?? "Untitled"
        self.imageFrontId = imageFrontId
        self.imageBackId = imageBackId
        self.cardColor = cardColor
        self.colorOpacity = colorOpacity
        self.modsIdentifiers = modsIdentifiers
        self.rightsStatement = rightsStatement
        self._notesArray = notes
        
        // Initialize empty relationships
        self.crops = []
        self.collections = []
        self.authors = []
        self.subjects = []
        self.dates = []
    }
}

// MARK: - Convenience Methods
extension StereoCard {
    var imageUrl: URL? {
        guard let imageFrontId else { return nil }
        return URL(
            string:
                "https://iiif-prod.nypl.org/index.php?id=\(imageFrontId)&t=w")
    }

    var backImageUrl: URL? {
        guard let imageBackId else { return nil }
        return URL(
            string: "https://iiif-prod.nypl.org/index.php?id=\(imageBackId)&t=w"
        )
    }

    func addToCollection(_ collection: Collection) {
        guard !collections.contains(collection) else { return }
        collections.append(collection)
        collection.addCard(self)
    }

    func removeFromCollection(_ collection: Collection) {
        collections.removeAll { $0.id == collection.id }
        collection.removeCard(self)
    }
}
