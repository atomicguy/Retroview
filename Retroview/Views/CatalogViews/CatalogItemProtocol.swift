//
//  CatalogItemProtocol.swift
//  Retroview
//
//  Created by Adam Schuster on 12/23/24.
//

import SwiftData

protocol CatalogItem: PersistentModel, Identifiable {
    var displayName: String { get }
    var cards: [CardSchemaV1.StereoCard] { get }
}

// Conform existing types to CatalogItem
extension AuthorSchemaV1.Author: CatalogItem {
    var displayName: String { name }
}

extension SubjectSchemaV1.Subject: CatalogItem {
    var displayName: String { name }
}

extension DateSchemaV1.Date: CatalogItem {
    var displayName: String { text }
}
