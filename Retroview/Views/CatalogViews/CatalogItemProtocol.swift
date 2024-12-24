//
//  CatalogItemProtocol.swift
//  Retroview
//
//  Created by Adam Schuster on 12/23/24.
//

import SwiftData

protocol CatalogItem: PersistentModel, Identifiable {
    var name: String { get }
    var cards: [CardSchemaV1.StereoCard] { get }
}

// Conform existing types to CatalogItem
extension AuthorSchemaV1.Author: CatalogItem {}
extension SubjectSchemaV1.Subject: CatalogItem {}
