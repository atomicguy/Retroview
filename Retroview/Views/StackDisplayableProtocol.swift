//
//  StackDisplayableProtocol.swift
//  Retroview
//
//  Created by Adam Schuster on 1/19/25.
//

import SwiftUI
import SwiftData

protocol StackDisplayable {
    var stackTitle: String { get }
    var stackCards: [CardSchemaV1.StereoCard] { get }
    var thumbnailData: Data? { get set }
}

// Default implementation for collections
extension CollectionSchemaV1.Collection: StackDisplayable {
    var stackTitle: String { name }
    var stackCards: [CardSchemaV1.StereoCard] { orderedCards }
    
    // Map the collection's thumbnail property to match protocol requirement
    var thumbnailData: Data? {
        get { collectionThumbnail }
        set { collectionThumbnail = newValue }
    }
}

// Default implementation for catalog items
extension CatalogItem {
    var stackTitle: String { name }
    var stackCards: [CardSchemaV1.StereoCard] { cards }
}
