//
//  CatalogEntries.swift
//  Retroview
//
//  Created by Adam Schuster on 12/22/24.
//

import SwiftData
import SwiftUI

protocol CatalogItem: PersistentModel, Identifiable {
    var name: String { get }
    var cards: [CardSchemaV1.StereoCard] { get }
}

// Conform existing types to CatalogItem
extension AuthorSchemaV1.Author: CatalogItem {}
extension SubjectSchemaV1.Subject: CatalogItem {}
